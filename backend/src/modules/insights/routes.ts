import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../lib/db.js';
import { AppError } from '../../lib/errors.js';

type LifecycleSummaryShape = {
  totalSteps: number;
  totalDistanceKm: number;
  retirementRiskLevel: string;
  confidenceScore: number | null;
};

function withLifecycleSummaries<T extends { id: string }>(
  items: T[],
  summaryMap: Map<string, LifecycleSummaryShape>
) {
  return items.map(item => ({
    ...item,
    lifecycleSummary: summaryMap.get(item.id) ?? null,
  }));
}

export async function insightRoutes(app: FastifyInstance) {
  app.get('/home-summary', async request => {
    const query = z.object({ userId: z.string() }).parse(request.query);

    const user = await prisma.user.findUnique({ where: { id: query.userId } });
    if (!user) {
      throw new AppError('User not found', 404);
    }

    const activeFootwear = await prisma.footwearItem.findMany({
      where: { userId: query.userId, status: 'active' },
      orderBy: { updatedAt: 'desc' },
      take: 3,
    });

    const unassignedWear = await prisma.wearEvent.findMany({
      where: { userId: query.userId, assignmentStatus: 'unassigned' },
    });

    const today = new Date().toISOString().slice(0, 10);
    const todayWear = await prisma.wearEvent.findMany({
      where: {
        userId: query.userId,
        eventDate: {
          gte: new Date(`${today}T00:00:00.000Z`),
          lte: new Date(`${today}T23:59:59.999Z`),
        },
      },
    });

    const currentDefault = await prisma.footwearItem.findFirst({
      where: { userId: query.userId, isDefaultFallback: true, status: 'active' },
    });

    const relevantIds = Array.from(
      new Set([
        ...activeFootwear.map(item => item.id),
        ...(currentDefault ? [currentDefault.id] : []),
      ])
    );

    const summaries = await prisma.lifecycleSummary.findMany({
      where: { footwearItemId: { in: relevantIds } },
    });
    const summaryMap = new Map<string, LifecycleSummaryShape>(
      summaries.map(summary => [
        summary.footwearItemId,
        {
          totalSteps: summary.totalSteps,
          totalDistanceKm: summary.totalDistanceKm,
          retirementRiskLevel: summary.retirementRiskLevel,
          confidenceScore: summary.confidenceScore ?? null,
        },
      ])
    );

    return {
      today: {
        steps: todayWear.reduce((sum, e) => sum + (e.stepsCount ?? 0), 0),
        distanceKm: todayWear.reduce((sum, e) => sum + (e.distanceKm ?? 0), 0),
      },
      activeFootwear: withLifecycleSummaries(activeFootwear, summaryMap),
      currentDefault: currentDefault ? withLifecycleSummaries([currentDefault], summaryMap)[0] : null,
      unassignedWear: {
        count: unassignedWear.length,
        steps: unassignedWear.reduce((sum, e) => sum + (e.stepsCount ?? 0), 0),
        distanceKm: unassignedWear.reduce((sum, e) => sum + (e.distanceKm ?? 0), 0),
      },
    };
  });

  app.get('/insights', async request => {
    const query = z.object({ userId: z.string() }).parse(request.query);

    const user = await prisma.user.findUnique({ where: { id: query.userId } });
    if (!user) {
      throw new AppError('User not found', 404);
    }

    const footwear = await prisma.footwearItem.findMany({
      where: { userId: query.userId },
    });
    const activeFootwear = footwear.filter(item => item.status === 'active');
    const inactiveFootwear = footwear.filter(item => item.status !== 'active');

    const lifecycleSummaries = await prisma.lifecycleSummary.findMany({
      where: { footwearItemId: { in: footwear.map(f => f.id) } },
    });

    const conditionLogs = await prisma.conditionLog.findMany({
      where: { footwearItemId: { in: footwear.map(f => f.id) } },
      orderBy: { loggedAt: 'desc' },
    });

    const summaryMap = new Map<string, LifecycleSummaryShape>(
      lifecycleSummaries.map(summary => [
        summary.footwearItemId,
        {
          totalSteps: summary.totalSteps,
          totalDistanceKm: summary.totalDistanceKm,
          retirementRiskLevel: summary.retirementRiskLevel,
          confidenceScore: summary.confidenceScore ?? null,
        },
      ])
    );

    const latestConditionMap = new Map<string, number>();
    for (const log of conditionLogs) {
      if (!latestConditionMap.has(log.footwearItemId)) {
        latestConditionMap.set(log.footwearItemId, log.overallConfidenceScore);
      }
    }

    const mostWorn = withLifecycleSummaries(
      [...activeFootwear]
        .sort((a, b) => (summaryMap.get(b.id)?.totalSteps ?? 0) - (summaryMap.get(a.id)?.totalSteps ?? 0))
        .slice(0, 5),
      summaryMap,
    );

    const needsAttention = withLifecycleSummaries(
      [...activeFootwear]
        .sort((a, b) => (latestConditionMap.get(a.id) ?? 999) - (latestConditionMap.get(b.id) ?? 999))
        .slice(0, 5),
      summaryMap,
    );

    const nearRetirement = withLifecycleSummaries(
      activeFootwear.filter(f => summaryMap.get(f.id)?.retirementRiskLevel === 'high'),
      summaryMap,
    );

    const inactiveHistory = withLifecycleSummaries(
      [...inactiveFootwear]
        .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime())
        .slice(0, 10),
      summaryMap,
    );

    return {
      mostWorn,
      needsAttention,
      nearRetirement,
      inactiveHistory,
    };
  });
}
