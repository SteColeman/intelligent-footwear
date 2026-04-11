import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  await prisma.user.upsert({
    where: { authProviderId: 'demo-user' },
    update: {},
    create: {
      authProviderId: 'demo-user',
      onboardingStatus: 'onboarding_complete',
      healthConnectionStatus: 'connected',
      timezone: 'Europe/London',
      locale: 'en-GB',
    },
  });

  console.log('Seeded demo-user');
}

main()
  .catch(err => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
