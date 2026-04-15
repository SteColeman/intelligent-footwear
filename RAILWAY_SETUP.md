# Railway Setup

## Goal
Deploy the backend to Railway with a hosted Postgres database so the iPhone app can talk to a real reachable backend.

## Recommended setup
- 1 Railway Postgres service
- 1 Railway app service for the Fastify backend

## Steps
1. Push latest repo to GitHub
2. Create a Railway project
3. Add a Postgres service
4. Add the backend service from GitHub
5. Set service root to `mvp-build/backend` if needed
6. Railway can use the included `railway.json`
7. Confirm environment includes:
   - `DATABASE_URL`
   - `PORT` if required
8. Deploy
9. Confirm:
   - `/health`
   - `/dev/bootstrap-demo-user`
   - `/me?authProviderId=demo-user`

## Suggested build/runtime path
- build: `npm install && npm run prisma:generate && npm run build`
- start: `npm run prisma:migrate:deploy && npm run start`

## After deploy
Use the deployed HTTPS URL as `FOOTWEAR_BACKEND_URL` in the Xcode scheme environment.

## Important note
Do not use `localhost` for physical device testing. Use the real Railway URL.
