# Render Setup

## Goal
Deploy the backend to Render with a hosted Postgres database so the iPhone app can talk to a real reachable backend.

## Recommended setup
- 1 Render Postgres database
- 1 Render Web Service for the Fastify backend

## Steps
1. Push latest repo to GitHub
2. Create a Postgres database in Render
3. Copy the external connection string
4. Create a new Web Service from this repo
5. Set root directory to `mvp-build/backend` if configuring from the repo root, or `backend` if deploying from the build folder directly
6. Use build command:
   - `npm install && npm run prisma:generate && npm run build`
7. Use start command:
   - `npm run prisma:migrate:deploy && npm run start`
8. Set environment variables:
   - `DATABASE_URL`
   - `PORT` (optional if Render injects it)
9. Deploy
10. Confirm:
   - `/health`
   - `/dev/bootstrap-demo-user`
   - `/me?authProviderId=demo-user`

## After deploy
Use the deployed HTTPS URL as `FOOTWEAR_BACKEND_URL` in the Xcode scheme environment.

## Important note
Do not use `localhost` for physical device testing. Use the real Render URL.
