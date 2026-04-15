# Hosted Runtime Switchover Checklist

## Goal
Move from local backend assumptions to a hosted backend that the simulator and physical iPhone can actually reach.

## Backend hosting
- [ ] choose provider (Railway or Render recommended)
- [ ] provision hosted Postgres
- [ ] set hosted `DATABASE_URL`
- [ ] deploy backend from `mvp-build/backend`
- [ ] run `npm run prisma:migrate:deploy`
- [ ] confirm `/health`
- [ ] confirm `/dev/bootstrap-demo-user`
- [ ] confirm `/me?authProviderId=demo-user`

## App switchover
- [ ] set `FOOTWEAR_BACKEND_URL` in Xcode scheme environment to the real hosted HTTPS backend URL
- [ ] confirm simulator can reach hosted backend
- [ ] confirm physical iPhone can reach hosted backend
- [ ] complete onboarding against hosted backend
- [ ] create footwear against hosted backend
- [ ] edit metadata/status against hosted backend
- [ ] change/remove photo against hosted backend
- [ ] import/assign against hosted backend
- [ ] confirm Home / Insights use hosted data

## Regression after switchover
- [ ] relaunch app and confirm onboarding state persists
- [ ] relaunch app and confirm footwear/photo state persists
- [ ] retire/archive/reactivate flows still behave correctly
- [ ] insights active/inactive separation still behaves correctly

## Honest note
This checklist assumes backend deployment is real and reachable. It does not pretend that local `localhost` behavior proves real device readiness.

For the shortest operator path, use:
- `GO_LIVE_CHECKLIST.md`
