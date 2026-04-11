import Fastify from 'fastify';
import cors from '@fastify/cors';
import 'dotenv/config';
import { ZodError } from 'zod';
import { userRoutes } from './modules/users/routes.js';
import { footwearRoutes } from './modules/footwear/routes.js';
import { healthImportRoutes } from './modules/health_import/routes.js';
import { assignmentRoutes } from './modules/assignments/routes.js';
import { conditionLogRoutes } from './modules/condition_logs/routes.js';
import { lifecycleRoutes } from './modules/lifecycle/routes.js';
import { insightRoutes } from './modules/insights/routes.js';
import { AppError } from './lib/errors.js';

const app = Fastify({ logger: true });

await app.register(cors);

app.setErrorHandler((error, _, reply) => {
  if (error instanceof AppError) {
    return reply.code(error.statusCode).send({
      error: {
        code: 'APP_ERROR',
        message: error.message,
      },
    });
  }

  if (error instanceof ZodError) {
    return reply.code(400).send({
      error: {
        code: 'VALIDATION_ERROR',
        message: error.issues.map(issue => issue.message).join('; '),
        details: error.issues,
      },
    });
  }

  return reply.code(500).send({
    error: {
      code: 'INTERNAL_ERROR',
      message: error.message,
    },
  });
});

app.get('/health', async () => ({ ok: true, service: 'footwear-intelligence-backend' }));
app.get('/', async () => ({ name: 'Footwear Intelligence API', status: 'connected-prototype' }));

await userRoutes(app);
await footwearRoutes(app);
await healthImportRoutes(app);
await assignmentRoutes(app);
await conditionLogRoutes(app);
await lifecycleRoutes(app);
await insightRoutes(app);

const port = Number(process.env.PORT || 3000);

app.listen({ port, host: '0.0.0.0' }).then(() => {
  app.log.info(`server listening on ${port}`);
});
