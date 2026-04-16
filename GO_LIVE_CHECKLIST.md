# Go Live Checklist

## Goal
Get the backend live on a hosted provider, point the app at it, and run the first honest simulator/device validation pass.

## 1. Pick provider
Choose one:
- Railway
- Render

Use the matching runbook:
- `RAILWAY_SETUP.md`
- `RENDER_SETUP.md`

## 2. Provision hosted database
- create hosted Postgres
- copy the external connection string
- confirm SSL requirements

## 3. Deploy backend
From the latest pushed repo state:
- root runtime path: `mvp-build/backend`
- build: `npm install && npm run prisma:generate && npm run build`
- start: `npm run prisma:migrate:deploy && npm run start`

## 4. Set env
Required:
- `DATABASE_URL`
- `PORT` if platform requires it

Reference:
- `backend/.env.hosted.example`

## 5. Verify backend
Fastest path:
```bash
cd mvp-build/backend
BACKEND_BASE_URL=https://your-hosted-backend.example.com npm run smoke:hosted
```

Manual checks if needed:
- `/health`
- `/`
- `POST /dev/bootstrap-demo-user`
- `GET /me?authProviderId=demo-user`
- `POST /me/onboarding-complete`
- `POST /me/health-connected`
- `POST /footwear`
- `PATCH /footwear/:id`
- `PATCH /footwear/:id/photo`
- `GET /home-summary?userId=...`
- `GET /insights?userId=...`

## 6. Switch app to hosted backend
In Xcode scheme environment variables:
- key: `FOOTWEAR_BACKEND_URL`
- value: hosted HTTPS backend URL

## 7. Simulator validation
- boot app
- bootstrap demo user
- complete onboarding
- add footwear
- edit metadata/status
- add/change/remove photo
- import/assign
- verify Home / Insights

## 8. Physical device validation
- install app on phone
- confirm hosted backend reachable
- repeat onboarding/create/edit/photo/import/assign flows
- relaunch app
- verify persistence and lifecycle-state behavior

## 9. Regression focus
Pay extra attention to:
- inactive pair losing default fallback
- archived pair refusing fresh condition logs
- retired pair still allowing condition logs
- insights active/inactive separation staying correct after status changes

## 10. After first live pass
- fix surfaced issues only
- rerun regression
- update docs to match truth
- checkpoint and push again

## Honest note
The plan is not complete until this checklist has been executed against a real hosted backend and a real physical device.
