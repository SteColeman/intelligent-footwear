import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../lib/db.js';
import { recomputeLifecycleSummary } from '../lifecycle/routes.js';
import { AppError } from '../../lib/errors.js';

const conditionLogSchema = z.object({
  userId: z.string(),
  footwearItemId: z.string(),
  comfortScore: z.number().min(1).max(5),
  cushioningScore: z.number().min(1).max(5),
  supportScore: z.number().min(1).max(5),
  gripScore: z.number().min(1).max(5),
  upperConditionScore: z.number().min(1).max(5),
  waterproofingScore: z.number().min(1).max(5).nullable().optional(),
  overallConfidenceScore: z.number().min(1).max(5),
  painFlag: z.boolean().optional(),
  notes: z.string().optional(),
  photoUrl: z.string().optional(),
});

export async function conditionLogRoutes(app: FastifyInstance) {
  app.post('/condition-logs', async request => {
    const body = conditionLogSchema.parse(request.body);

    const footwear = await prisma.footwearItem.findUnique({ where: { id: body.footwearItemId } });
    if (!footwear || footwear.userId !== body.userId) {
      throw new AppError('Footwear item not found for user', 404);
    }

    if (footwear.status === 'archived') {
      throw new AppError('Archived footwear cannot accept new condition logs', 400);
    }

    const log = await prisma.conditionLog.create({
      data: {
        userId: body.userId,
        footwearItemId: body.footwearItemId,
        comfortScore: body.comfortScore,
        cushioningScore: body.cushioningScore,
        supportScore: body.supportScore,
        gripScore: body.gripScore,
        upperConditionScore: body.upperConditionScore,
        waterproofingScore: body.waterproofingScore ?? null,
        overallConfidenceScore: body.overallConfidenceScore,
        painFlag: body.painFlag ?? false,
        notes: body.notes,
        photoUrl: body.photoUrl,
      },
    });

    await recomputeLifecycleSummary(body.footwearItemId);

    return log;
  });

  app.get('/footwear/:id/condition-logs', async request => {
    const params = z.object({ id: z.string() }).parse(request.params);
    const query = z.object({ userId: z.string() }).parse(request.query);

    const footwear = await prisma.footwearItem.findUnique({ where: { id: params.id } });
    if (!footwear || footwear.userId !== query.userId) {
      throw new AppError('Footwear item not found for user', 404);
    }

    return prisma.conditionLog.findMany({
      where: { footwearItemId: params.id },
      orderBy: { loggedAt: 'desc' },
    });
  });
}
