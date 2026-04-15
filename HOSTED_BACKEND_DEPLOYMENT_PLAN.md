# Hosted Backend Deployment Plan

## Goal
Move the backend from local prototype assumptions to a hosted runtime that can be reached by a physical iPhone.

## Recommended path
Use:
- hosted Postgres
- hosted Node service

Good options:
- Railway
- Render

Provider-specific runbooks:
- `RAILWAY_SETUP.md`
- `RENDER_SETUP.md`

This project does not need a fancy platform decision yet. It needs the fastest path to a reachable, honest MVP backend.

## Preferred order
1. Provision hosted Postgres
2. Set `DATABASE_URL`
3. Build backend successfully
4. Add production start command
5. Deploy Fastify backend
6. Run Prisma migrations against hosted DB
7. Verify health and core endpoints
8. Point iOS app at hosted backend URL
9. Test on simulator
10. Test on physical device

## Required backend runtime inputs
- `DATABASE_URL`
- `PORT`
- any future CORS/base-url config if needed

## Current backend gaps before hosted deployment
- migration flow is still named for local dev use (`prisma migrate dev`)
- no explicit production migration/deploy script yet
- docs still assume local Docker in several places
- no checked-in hosted deployment runbook existed before this file

## Minimum hosted deployment checklist
- [ ] hosted Postgres provisioned
- [ ] backend environment variables configured
- [ ] `npm install` works in hosted build
- [ ] `npm run prisma:generate` works in hosted build
- [ ] production migration command available
- [ ] `npm run build` works
- [ ] `npm run start` works
- [ ] `/health` reachable publicly or via intended protected URL
- [ ] `/me?authProviderId=demo-user` works against hosted DB
- [ ] onboarding/status/photo routes work against hosted DB

## Recommended first provider configuration
### Railway / Render style
- Build command: `npm install && npm run prisma:generate && npm run build`
- Start command: `npm run start`
- Post-deploy migration command: `npm run prisma:migrate:deploy`

## Smoke test after deployment
- `GET /health`
- `GET /`
- `POST /dev/bootstrap-demo-user`
- `GET /me?authProviderId=demo-user`
- `POST /footwear`
- `PATCH /footwear/:id`
- `PATCH /footwear/:id/photo`
- `GET /home-summary?userId=...`
- `GET /insights?userId=...`

## Honest note
This project is still a connected MVP prototype. Hosted deployment is about making it testable on a real phone with a real reachable backend, not pretending it is already production-grade infrastructure.

For the shortest operator path, use:
- `GO_LIVE_CHECKLIST.md`
