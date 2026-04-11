import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../lib/db.js';
import { AppError } from '../../lib/errors.js';

export async function recomputeLifecycleSummary(footwearItemId: string) {
  const assignments = await prisma.assignment.findMany({
    where: { footwearItemId },
    include: { wearEvent: true },
  });

  const totalSteps = assignments.reduce((sum, a) => sum + (a.wearEvent.stepsCount ?? 0), 0);
  const totalDistanceKm = assignments.reduce((sum, a) => sum + (a.wearEvent.distanceKm ?? 0), 0);
  const assignedDaysCount = new Set(assignments.map(a => a.wearEvent.eventDate.toISOString().slice(0, 10))).size;
  const lastUsedAt = assignments.length
    ? new Date(Math.max(...assignments.map(a => a.wearEvent.eventDate.getTime())))
    : null;

  const footwear = await prisma.footwearItem.findUnique({
    where: { id: footwearItemId },
  });

  const progressBySteps = footwear?.targetSteps ? totalSteps / footwear.targetSteps : null;
  const progressByDistance = footwear?.targetDistanceKm ? totalDistanceKm / footwear.targetDistanceKm : null;
  const lifecycleProgressPct = progressBySteps ?? progressByDistance ?? null;

  const latestCondition = await prisma.conditionLog.findFirst({
    where: { footwearItemId },
    orderBy: { loggedAt: 'desc' },
  });

  const confidenceScore = latestCondition ? latestCondition.overallConfidenceScore / 5 : lifecycleProgressPct ? 0.6 : null;

  let retirementRiskLevel = 'low';
  if ((lifecycleProgressPct && lifecycleProgressPct >= 0.85) || (latestCondition && latestCondition.overallConfidenceScore <= 2)) {
    retirementRiskLevel = 'high';
  } else if ((lifecycleProgressPct && lifecycleProgressPct >= 0.65) || (latestCondition && latestCondition.overallConfidenceScore <= 3)) {
    retirementRiskLevel = 'medium';
  }

  return prisma.lifecycleSummary.upsert({
    where: { footwearItemId },
    update: {
      totalSteps,
      totalDistanceKm,
      assignedDaysCount,
      lastUsedAt,
      lifecycleProgressPct,
      retirementRiskLevel,
      confidenceScore,
    },
    create: {
      footwearItemId,
      totalSteps,
      totalDistanceKm,
      assignedDaysCount,
      lastUsedAt,
      lifecycleProgressPct,
      retirementRiskLevel,
      confidenceScore,
    },
  });
}

export async function lifecycleRoutes(app: FastifyInstance) {
  app.get('/footwear/:id/lifecycle-summary', async request => {
    const params = z.object({ id: z.string() }).parse(request.params);
    const query = z.object({ userId: z.string() }).parse(request.query);

    const footwear = await prisma.footwearItem.findUnique({ where: { id: params.id } });
    if (!footwear || footwear.userId !== query.userId) {
      throw new AppError('Footwear item not found for user', 404);
    }

    return prisma.lifecycleSummary.findUnique({ where: { footwearItemId: params.id } });
  });
}
