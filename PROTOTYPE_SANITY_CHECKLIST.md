# Prototype Sanity Checklist

## Goal
Use this checklist to move the current prototype from connected codebase to something that can be exercised end-to-end.

See also:
- `HANDOFF_READINESS.md`
- `MOVE_TO_MAC_THRESHOLD.md`
- `FIRST_REPO_BOOTSTRAP.md`

## Backend sanity
- [x] `.env` copied from `.env.example`
- [ ] reachable PostgreSQL runtime available
- [x] `npm install` completed
- [x] `npm run prisma:generate` completed
- [ ] `npm run prisma:migrate` completed
- [ ] `npm run seed` completed
- [ ] `npm run dev` running against live DB
- [ ] `/health` returns OK
- [ ] `/me?authProviderId=demo-user` returns seeded user

## Backend flow sanity
- [ ] create footwear works
- [ ] health import works
- [ ] unassigned wear appears
- [ ] assignment works
- [ ] condition log works
- [ ] lifecycle summary updates
- [ ] home summary updates
- [ ] insights summary updates

## iOS sanity
- [ ] SwiftUI source compiles inside a real Xcode target
- [ ] HealthKit capability enabled
- [ ] Health usage string added
- [ ] app boots into onboarding or main flow correctly
- [ ] backend base URL reachable from simulator/device

## Flow sanity
- [ ] complete onboarding
- [ ] connect Apple Health
- [ ] add first footwear
- [ ] import health data
- [ ] assign wear
- [ ] log condition
- [ ] review Home and Insights

## Known current blockers
- no Docker/PostgreSQL runtime in current Linux environment
- actual Xcode project shell still needed
- auth is prototype-level
- no formal automated test suite yet
