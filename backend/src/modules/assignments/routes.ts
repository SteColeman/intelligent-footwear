import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../lib/db.js';
import { recomputeLifecycleSummary } from '../lifecycle/routes.js';
import { AppError } from '../../lib/errors.js';

const createAssignmentSchema = z.object({
  userId: z.string(),
  wearEventId: z.string(),
  footwearItemId: z.string(),
  assignmentMethod: z.enum(['manual', 'fallback_default', 'rule_based', 'predicted']),
  assignmentConfidence: z.number().min(0).max(1).optional(),
  confirmedByUser: z.boolean().optional(),
});

export async function assignmentRoutes(app: FastifyInstance) {
  app.post('/assignments', async request => {
    const body = createAssignmentSchema.parse(request.body);

    const wearEvent = await prisma.wearEvent.findUnique({ where: { id: body.wearEventId } });
    if (!wearEvent || wearEvent.userId !== body.userId) {
      throw new AppError('Wear event not found for user', 404);
    }

    const footwear = await prisma.footwearItem.findUnique({ where: { id: body.footwearItemId } });
    if (!footwear || footwear.userId !== body.userId) {
      throw new AppError('Footwear item not found for user', 404);
    }

    const existing = await prisma.assignment.findUnique({ where: { wearEventId: body.wearEventId } });
    const previousFootwearItemId = existing?.footwearItemId;

    const assignment = await prisma.assignment.upsert({
      where: { wearEventId: body.wearEventId },
      update: {
        footwearItemId: body.footwearItemId,
        assignmentMethod: body.assignmentMethod,
        assignmentConfidence: body.assignmentConfidence,
        confirmedByUser: body.confirmedByUser ?? body.assignmentMethod === 'manual',
      },
      create: {
        userId: body.userId,
        wearEventId: body.wearEventId,
        footwearItemId: body.footwearItemId,
        assignmentMethod: body.assignmentMethod,
        assignmentConfidence: body.assignmentConfidence,
        confirmedByUser: body.confirmedByUser ?? body.assignmentMethod === 'manual',
      },
    });

    await prisma.wearEvent.update({
      where: { id: body.wearEventId },
      data: { assignmentStatus: 'assigned' },
    });

    if (previousFootwearItemId && previousFootwearItemId !== body.footwearItemId) {
      await recomputeLifecycleSummary(previousFootwearItemId);
    }
    await recomputeLifecycleSummary(body.footwearItemId);

    return assignment;
  });

  app.delete('/assignments/:id', async request => {
    const params = z.object({ id: z.string() }).parse(request.params);

    const assignment = await prisma.assignment.findUnique({ where: { id: params.id } });
    if (!assignment) {
      throw new AppError('Assignment not found', 404);
    }

    await prisma.assignment.delete({ where: { id: params.id } });
    await prisma.wearEvent.update({
      where: { id: assignment.wearEventId },
      data: { assignmentStatus: 'unassigned' },
    });

    await recomputeLifecycleSummary(assignment.footwearItemId);

    return { ok: true };
  });

  app.post('/assignments/bulk-default', async request => {
    const body = z.object({
      userId: z.string(),
      wearEventIds: z.array(z.string()).min(1),
    }).parse(request.body);

    const defaultFootwear = await prisma.footwearItem.findFirst({
      where: {
        userId: body.userId,
        isDefaultFallback: true,
        status: 'active',
      },
    });

    if (!defaultFootwear) {
      throw new AppError('No default footwear set', 400);
    }

    const wearEvents = await prisma.wearEvent.findMany({
      where: { id: { in: body.wearEventIds } },
      select: { id: true, userId: true },
    });

    const invalidWearEvent = body.wearEventIds.find(id => !wearEvents.some(event => event.id === id && event.userId === body.userId));
    if (invalidWearEvent) {
      throw new AppError('One or more wear events were not found for user', 404);
    }

    for (const wearEventId of body.wearEventIds) {
      await prisma.assignment.upsert({
        where: { wearEventId },
        update: {
          footwearItemId: defaultFootwear.id,
          assignmentMethod: 'fallback_default',
          assignmentConfidence: 0.5,
          confirmedByUser: false,
        },
        create: {
          userId: body.userId,
          wearEventId,
          footwearItemId: defaultFootwear.id,
          assignmentMethod: 'fallback_default',
          assignmentConfidence: 0.5,
          confirmedByUser: false,
        },
      });

      await prisma.wearEvent.update({
        where: { id: wearEventId },
        data: { assignmentStatus: 'assigned' },
      });
    }

    await recomputeLifecycleSummary(defaultFootwear.id);

    return { ok: true, assignedTo: defaultFootwear.id, count: body.wearEventIds.length };
  });
}
