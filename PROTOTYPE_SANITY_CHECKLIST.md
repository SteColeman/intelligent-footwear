# Prototype Sanity Checklist

## Goal
Use this checklist to validate the current connected prototype honestly on Mac / Xcode / device, especially after the newer onboarding persistence, warm-UI, footwear photo work, and lifecycle-state management.

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
- [ ] `PATCH /footwear/:id` route confirmed live

## iOS / Xcode sanity
- [x] checked-in Xcode project exists
- [ ] current code compiles in Xcode after latest pull
- [ ] app launches successfully in simulator or device
- [ ] backend base URL reachable from simulator/device
- [ ] new `Core/Photos/FootwearPhotoStore.swift` is included in target membership
- [ ] new `Core/UI/FootwearPhotoView.swift` is included in target membership
- [ ] PhotosUI additions compile cleanly

## Core flow sanity
- [ ] bootstrap user succeeds
- [ ] onboarding completes once
- [ ] app relaunch does **not** return to onboarding
- [ ] Apple Health step behaves sensibly (connect or skip)
- [ ] add first footwear works
- [ ] add second footwear works
- [ ] editing footwear metadata works
- [ ] changing default footwear works
- [ ] changing status to retired works
- [ ] changing status to archived works
- [ ] returning archived/retired footwear to active works
- [ ] default footwear behavior remains sane after status changes
- [ ] import demo data works
- [ ] repeated import does not create obviously broken state
- [ ] unassigned wear appears when expected
- [ ] assignment works
- [ ] only active footwear appears in normal assignment targets
- [ ] repeated assign/list/detail refresh stays sane
- [ ] condition log works for active footwear
- [ ] condition log still works for retired footwear if intended
- [ ] archived footwear cannot create fresh condition logs
- [ ] inactive footwear is not treated like active footwear in the UI

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
- [ ] photo survives metadata/status edits

## Home / Insights sanity
- [ ] Home loads after onboarding and footwear creation
- [ ] Home rotation shows only active footwear
- [ ] inactive footwear does not muddy active rotation copy
- [ ] default footwear copy stays sane if the default pair becomes inactive
- [ ] Insights loads after import/assignment
- [ ] backend insights payload returns active primary sections and explicit inactive history
- [ ] primary insight sections focus on active footwear
- [ ] inactive footwear appears only in intentional historical treatment

## Known current blockers
- no Docker/PostgreSQL runtime in current Linux environment
- full repeated runtime validation still depends on Mac/device testing
- photo persistence is local prototype persistence, not full cloud-backed media storage
- no formal automated UI/integration suite yet
