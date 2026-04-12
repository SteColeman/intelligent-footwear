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
    const user = await prisma.user.upsert({
      where: { authProviderId: 'demo-user' },
      update: {
        onboardingStatus: 'onboarding_incomplete',
        healthConnectionStatus: 'not_connected',
      },
      create: {
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
}
