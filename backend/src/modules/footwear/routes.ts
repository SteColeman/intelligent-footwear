import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../lib/db.js';
import { recomputeLifecycleSummary } from '../lifecycle/routes.js';
import { AppError } from '../../lib/errors.js';

const createFootwearSchema = z.object({
  userId: z.string(),
  brand: z.string().min(1),
  model: z.string().min(1),
  nickname: z.string().optional(),
  category: z.string().min(1),
  purchaseDate: z.string().optional(),
  startUseDate: z.string().optional(),
  targetSteps: z.number().int().positive().optional(),
  targetDistanceKm: z.number().positive().optional(),
  isDefaultFallback: z.boolean().optional(),
  photoUrl: z.string().optional(),
  notes: z.string().optional(),
});

const updateFootwearPhotoSchema = z.object({
  userId: z.string(),
  photoUrl: z.string().nullable().optional(),
});

const updateFootwearSchema = z.object({
  userId: z.string(),
  brand: z.string().min(1),
  model: z.string().min(1),
  nickname: z.string().nullable().optional(),
  category: z.string().min(1),
  isDefaultFallback: z.boolean().optional(),
});

async function attachLifecycleSummary<T extends { id: string }>(items: T[]) {
  if (items.length === 0) {
    return [];
  }

  const summaries = await prisma.lifecycleSummary.findMany({
    where: { footwearItemId: { in: items.map(item => item.id) } },
  });

  const summaryMap = new Map(summaries.map(summary => [summary.footwearItemId, summary]));
  return items.map(item => ({
    ...item,
    lifecycleSummary: summaryMap.get(item.id) ?? null,
  }));
}

export async function footwearRoutes(app: FastifyInstance) {
  app.get('/footwear', async request => {
    const query = z.object({ userId: z.string() }).parse(request.query);

    const user = await prisma.user.findUnique({ where: { id: query.userId } });
    if (!user) {
      throw new AppError('User not found', 404);
    }

    const items = await prisma.footwearItem.findMany({
      where: { userId: query.userId },
      orderBy: { createdAt: 'desc' },
    });

    return attachLifecycleSummary(items);
  });

  app.post('/footwear', async request => {
    const body = createFootwearSchema.parse(request.body);

    const user = await prisma.user.findUnique({ where: { id: body.userId } });
    if (!user) {
      throw new AppError('User not found', 404);
    }

    const existingDefault = body.isDefaultFallback
      ? await prisma.footwearItem.findMany({
          where: { userId: body.userId, isDefaultFallback: true },
        })
      : [];

    if (existingDefault.length > 0) {
      await prisma.footwearItem.updateMany({
        where: { userId: body.userId, isDefaultFallback: true },
        data: { isDefaultFallback: false },
      });
    }

    const created = await prisma.footwearItem.create({
      data: {
        userId: body.userId,
        brand: body.brand,
        model: body.model,
        nickname: body.nickname,
        category: body.category,
        purchaseDate: body.purchaseDate ? new Date(body.purchaseDate) : undefined,
        startUseDate: body.startUseDate ? new Date(body.startUseDate) : undefined,
        targetSteps: body.targetSteps,
        targetDistanceKm: body.targetDistanceKm,
        isDefaultFallback: body.isDefaultFallback ?? false,
        photoUrl: body.photoUrl,
        status: 'active',
        notes: body.notes,
      },
    });

    await recomputeLifecycleSummary(created.id);
    const [itemWithSummary] = await attachLifecycleSummary([created]);
    return itemWithSummary;
  });

  app.patch('/footwear/:id', async request => {
    const params = z.object({ id: z.string() }).parse(request.params);
    const body = updateFootwearSchema.parse(request.body);

    const item = await prisma.footwearItem.findUnique({
      where: { id: params.id },
    });

    if (!item || item.userId !== body.userId) {
      throw new AppError('Footwear item not found for user', 404);
    }

    if (body.isDefaultFallback) {
      await prisma.footwearItem.updateMany({
        where: { userId: body.userId, isDefaultFallback: true },
        data: { isDefaultFallback: false },
      });
    }

    const updated = await prisma.footwearItem.update({
      where: { id: params.id },
      data: {
        brand: body.brand,
        model: body.model,
        nickname: body.nickname ?? null,
        category: body.category,
        isDefaultFallback: body.isDefaultFallback ?? item.isDefaultFallback,
      },
    });

    const [itemWithSummary] = await attachLifecycleSummary([updated]);
    return itemWithSummary;
  });

  app.patch('/footwear/:id/photo', async request => {
    const params = z.object({ id: z.string() }).parse(request.params);
    const body = updateFootwearPhotoSchema.parse(request.body);

    const item = await prisma.footwearItem.findUnique({
      where: { id: params.id },
    });

    if (!item || item.userId !== body.userId) {
      throw new AppError('Footwear item not found for user', 404);
    }

    const updated = await prisma.footwearItem.update({
      where: { id: params.id },
      data: {
        photoUrl: body.photoUrl ?? null,
      },
    });

    const [itemWithSummary] = await attachLifecycleSummary([updated]);
    return itemWithSummary;
  });

  app.get('/footwear/:id', async request => {
    const params = z.object({ id: z.string() }).parse(request.params);
    const query = z.object({ userId: z.string() }).parse(request.query);

    const item = await prisma.footwearItem.findUnique({
      where: { id: params.id },
    });

    if (!item || item.userId !== query.userId) {
      throw new AppError('Footwear item not found for user', 404);
    }

    const [itemWithSummary] = await attachLifecycleSummary([item]);
    return itemWithSummary;
  });
}
