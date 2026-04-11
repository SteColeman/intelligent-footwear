import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../lib/db.js';
import { AppError } from '../../lib/errors.js';

const wearEventSchema = z.object({
  eventDate: z.string(),
  eventType: z.string().min(1),
  stepsCount: z.number().int().nonnegative().nullable().optional(),
  distanceKm: z.number().nonnegative().nullable().optional(),
  startTime: z.string().optional(),
  endTime: z.string().optional(),
  sourceLabel: z.string().optional(),
});

const importSchema = z.object({
  userId: z.string(),
  importedAt: z.string(),
  startRange: z.string(),
  endRange: z.string(),
  sourceDevice: z.string().optional(),
  events: z.array(wearEventSchema),
});

function normalizeIso(value?: string | null) {
  return value ? new Date(value).toISOString() : 'null';
}

function eventFingerprint(userId: string, event: z.infer<typeof wearEventSchema>) {
  return [
    userId,
    normalizeIso(event.eventDate),
    event.eventType,
    event.stepsCount ?? 'null',
    event.distanceKm ?? 'null',
    normalizeIso(event.startTime),
    normalizeIso(event.endTime),
  ].join('::');
}

export async function healthImportRoutes(app: FastifyInstance) {
  app.post('/health/import-batch', async request => {
    const body = importSchema.parse(request.body);

    const importedAt = new Date(body.importedAt);
    const startRange = new Date(body.startRange);
    const endRange = new Date(body.endRange);

    if (Number.isNaN(importedAt.getTime()) || Number.isNaN(startRange.getTime()) || Number.isNaN(endRange.getTime())) {
      throw new AppError('Invalid import date payload', 400);
    }

    if (endRange < startRange) {
      throw new AppError('Import endRange must be after startRange', 400);
    }

    const user = await prisma.user.findUnique({ where: { id: body.userId } });
    if (!user) {
      throw new AppError('User not found for import', 404);
    }

    const batch = await prisma.healthImportBatch.create({
      data: {
        userId: body.userId,
        importedAt,
        startRange,
        endRange,
        sourceDevice: body.sourceDevice,
        importStatus: 'completed',
      },
    });

    let eventsAccepted = 0;
    let eventsDeduped = 0;

    const existing = await prisma.wearEvent.findMany({
      where: { userId: body.userId },
      select: {
        eventDate: true,
        eventType: true,
        stepsCount: true,
        distanceKm: true,
        startTime: true,
        endTime: true,
      },
    });

    const existingFingerprints = new Set(
      existing.map(event =>
        [
          body.userId,
          event.eventDate.toISOString(),
          event.eventType,
          event.stepsCount ?? 'null',
          event.distanceKm ?? 'null',
          event.startTime?.toISOString() ?? 'null',
          event.endTime?.toISOString() ?? 'null',
        ].join('::')
      )
    );

    for (const event of body.events) {
      const eventDate = new Date(event.eventDate);
      const startTime = event.startTime ? new Date(event.startTime) : null;
      const endTime = event.endTime ? new Date(event.endTime) : null;

      if (Number.isNaN(eventDate.getTime()) || (startTime && Number.isNaN(startTime.getTime())) || (endTime && Number.isNaN(endTime.getTime()))) {
        throw new AppError('Invalid event date payload', 400);
      }

      if (startTime && endTime && endTime < startTime) {
        throw new AppError('Event endTime must be after startTime', 400);
      }

      const fp = eventFingerprint(body.userId, event);
      if (existingFingerprints.has(fp)) {
        eventsDeduped += 1;
        continue;
      }

      await prisma.wearEvent.create({
        data: {
          userId: body.userId,
          importBatchId: batch.id,
          eventDate,
          startTime: startTime ?? undefined,
          endTime: endTime ?? undefined,
          eventType: event.eventType,
          stepsCount: event.stepsCount ?? null,
          distanceKm: event.distanceKm ?? null,
          assignmentStatus: 'unassigned',
          sourceLabel: event.sourceLabel,
        },
      });

      eventsAccepted += 1;
    }

    return {
      importBatchId: batch.id,
      eventsAccepted,
      eventsDeduped,
    };
  });

  app.get('/wear-events/unassigned', async request => {
    const query = z.object({ userId: z.string() }).parse(request.query);

    const user = await prisma.user.findUnique({ where: { id: query.userId } });
    if (!user) {
      throw new AppError('User not found', 404);
    }

    return prisma.wearEvent.findMany({
      where: {
        userId: query.userId,
        assignmentStatus: 'unassigned',
      },
      orderBy: { eventDate: 'desc' },
    });
  });
}
