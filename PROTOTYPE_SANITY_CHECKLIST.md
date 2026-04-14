# Prototype Sanity Checklist

## Goal
Use this checklist to validate the current connected prototype honestly on Mac / Xcode / device, especially after the newer onboarding persistence, warm-UI, and footwear photo work.

See also:
- `HANDOFF_READINESS.md`
- `VALIDATION_STATUS.md`
- `ios-app/PROJECT_STATUS.md`

## Backend sanity
- [x] `.env` copied from `.env.example`
- [ ] reachable PostgreSQL runtime available on the active validation machine
- [x] `npm install` completed
- [x] `npm run prisma:generate` completed
- [ ] `npm run prisma:migrate` completed on the current runtime
- [ ] `npm run seed` completed on the current runtime
- [ ] `npm run dev` running against live DB
- [ ] `/health` returns OK
- [ ] `/me?authProviderId=demo-user` returns live user
- [ ] `POST /me/onboarding-complete` route confirmed live
- [ ] `PATCH /footwear/:id/photo` route confirmed live

## iOS / Xcode sanity
- [x] checked-in Xcode project exists
- [ ] current code compiles in Xcode after latest pull
- [ ] app launches successfully in simulator or device
- [ ] backend base URL reachable from simulator/device
- [ ] new `Core/Photos/FootwearPhotoStore.swift` is included in target membership
- [ ] PhotosUI additions compile cleanly

## Core flow sanity
- [ ] bootstrap user succeeds
- [ ] onboarding completes once
- [ ] app relaunch does **not** return to onboarding
- [ ] Apple Health step behaves sensibly (connect or skip)
- [ ] add first footwear works
- [ ] add second footwear works
- [ ] changing default footwear behaves correctly
- [ ] import demo data works
- [ ] repeated import does not create obviously broken state
- [ ] unassigned wear appears when expected
- [ ] assignment works
- [ ] repeated assign/list/detail refresh stays sane
- [ ] condition log works
- [ ] repeated condition logging stays sane

## Photo feature sanity
- [ ] create footwear with no photo works
- [ ] create footwear with photo works
- [ ] photo preview works in create flow
- [ ] photo persists after save
- [ ] photo appears in Footwear List
- [ ] photo appears in Footwear Detail hero
- [ ] change photo from detail works
- [ ] remove photo from detail works
- [ ] relaunch app and photo still appears correctly
- [ ] missing/bad image fallback is acceptable

## Home / Insights sanity
- [ ] Home loads after onboarding and footwear creation
- [ ] rotation cards make sense after multiple footwear items
- [ ] default footwear appears correctly in Home
- [ ] Insights loads after import/assignment
- [ ] richer warm UI still behaves cleanly with real data

## Known current blockers
- no Docker/PostgreSQL runtime in current Linux environment
- full repeated runtime validation still depends on Mac/device testing
- photo persistence is local prototype persistence, not full cloud-backed media storage
- no formal automated UI/integration suite yet
