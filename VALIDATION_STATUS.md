# Validation Status

## Current status
This is still a **connected prototype**, not a fully validated MVP.

## What has been validated for real
### Backend / integration reality
- backend dependencies install cleanly
- Prisma client generation works
- backend route surface has been materially hardened
- backend now supports onboarding persistence updates
- backend now supports editable primary footwear photo updates (`PATCH /footwear/:id/photo`)

### iOS / Xcode reality
- working checked-in Xcode project exists
- app builds in real Xcode on Mac
- app launches in real Xcode on Mac
- core connected prototype loop has been exercised on Mac side
- onboarding path exists and has had real bug-fixing work around persistence
- shared warm-surface UI system now exists across core screens
- footwear photo identity feature now exists in the prototype:
  - create with photo
  - preview photo
  - local persistence
  - list/detail rendering
  - change/remove from detail

## What is still not validated enough
- repeated app relaunch behavior over multiple sessions
- repeated onboarding completion flow after fresh/repeat runs
- repeated import/dedupe behavior against realistic data
- multiple-footwear rotation behavior under repeated use
- default footwear behavior under repeated assignment flows
- automatic clearing of default fallback when footwear becomes inactive
- editable photo flows over repeated sessions on device
- retired vs archived condition-log behavior over repeated sessions
- active/inactive insights separation after repeated status transitions and reloads
- real Apple Health data path beyond happy-path validation
- full DB-backed validation from this Linux workspace

## Current hard blockers
- no `docker` available in this environment
- no local PostgreSQL runtime available in this environment
- true backend validation from here remains environment-limited

## Honest summary
The prototype is materially more real than the old docs suggest:
- there is a working Xcode project
- there has been real Mac-side build/run validation
- there is now a stronger UI system
- onboarding persistence and footwear photo identity are real prototype features

What is still missing is **repeatable runtime hardening**, not basic project existence.

## Nearest real milestone
- validate repeated relaunch/onboarding behavior
- validate repeated photo add/change/remove behavior
- validate repeated import/assign/detail flows on Mac/device
- keep the docs aligned with whatever the next real test proves

## Supporting reference docs
- `HANDOFF_READINESS.md`
- `ios-app/PROJECT_STATUS.md`
