# End-to-End Validation Notes

## Goal
Validate the real connected prototype loop:
1. bootstrap user
2. complete onboarding once
3. relaunch without onboarding regression
4. add footwear
5. optionally add photo
6. import wear
7. assign wear
8. log condition
9. inspect Home / Insights / Detail
10. relaunch again and confirm state persistence

See also:
- `HANDOFF_READINESS.md`
- `VALIDATION_STATUS.md`
- `ios-app/PROJECT_STATUS.md`

## Honest current state
Current status: **connected prototype with real Xcode/Mac progress, but still awaiting repeated runtime hardening**

## What has been validated so far
- backend dependencies install cleanly
- Prisma client generation works
- working checked-in Xcode project exists
- app has built and launched on Mac side
- core app surfaces exist and have been exercised in connected-prototype form
- onboarding persistence path has been implemented after real bug discovery
- primary footwear photo support now exists in the prototype
- shared warm-surface UI system exists across the main product loop

## What still needs repeated validation
- onboarding completion after repeated relaunches
- repeated import/dedupe behavior
- repeated add/edit/remove photo behavior
- multi-footwear/default-footwear behavior
- repeated condition logging behavior
- real Apple Health path beyond happy-path flows
- device behavior away from simulator comfort

## Environment caveat
This Linux build environment still does not have Docker/PostgreSQL locally, so true DB-backed end-to-end validation cannot be completed here.

## Practical next validation point
The next honest milestone is:
- backend running against a real DB on the Mac/testing setup
- app pulled/building from latest repo state
- repeated relaunch/onboarding/photo/import/assign/detail flows exercised in Xcode/device testing
