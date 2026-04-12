import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../lib/db.js';
import { AppError } from '../../lib/errors.js';

export async function userRoutes(app: FastifyInstance) {
  app.get('/me', async request => {
    const query = z.object({ authProviderId: z.string().min(1) }).parse(request.query);

    const user = await prisma.user.findUnique({
      where: { authProviderId: query.authProviderId },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    return user;
  });

  app.post('/dev/bootstrap-demo-user', async () => {
    const existing = await prisma.user.findUnique({
      where: { authProviderId: 'demo-user' },
    });

    const user = existing ?? await prisma.user.create({
      data: {
        authProviderId: 'demo-user',
        onboardingStatus: 'onboarding_incomplete',
        healthConnectionStatus: 'not_connected',
        timezone: 'Europe/London',
        locale: 'en-GB',
      },
    });

    return {
      authProviderId: user.authProviderId,
      userId: user.id,
      onboardingStatus: user.onboardingStatus,
      healthConnectionStatus: user.healthConnectionStatus,
    };
  });

  app.post('/me/onboarding-complete', async request => {
    const body = z.object({ userId: z.string().min(1) }).parse(request.body);

    const existing = await prisma.user.findUnique({
      where: { id: body.userId },
    });

    if (!existing) {
      throw new AppError('User not found', 404);
    }

    const user = await prisma.user.update({
      where: { id: body.userId },
      data: {
        onboardingStatus: 'onboarding_complete',
      },
    });

    return {
      id: user.id,
      onboardingStatus: user.onboardingStatus,
    };
  });

  app.post('/me/health-connected', async request => {
    const body = z.object({ userId: z.string().min(1) }).parse(request.body);

    const existing = await prisma.user.findUnique({
      where: { id: body.userId },
    });

    if (!existing) {
      throw new AppError('User not found', 404);
    }

    const user = await prisma.user.update({
      where: { id: body.userId },
      data: {
        healthConnectionStatus: 'connected',
      },
    });

    return {
      id: user.id,
      healthConnectionStatus: user.healthConnectionStatus,
    };
  });
}
