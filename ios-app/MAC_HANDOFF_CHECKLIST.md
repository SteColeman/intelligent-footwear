# Mac Handoff Checklist

Use this when the project is pushed to GitHub and opened on a Mac.

## Backend side
- [ ] clone repo
- [ ] open `mvp-build/backend`
- [ ] copy `.env.example` to `.env`
- [ ] run Docker Desktop or otherwise provide PostgreSQL
- [ ] run `npm install`
- [ ] run `npm run prisma:generate`
- [ ] run `npm run prisma:migrate`
- [ ] run `npm run seed`
- [ ] run `npm run dev`
- [ ] confirm `/health` responds
- [ ] confirm `/dev/bootstrap-demo-user` responds

## Xcode side
- [ ] create or open `FootwearIntelligence` iOS app project
- [ ] add the prototype Swift files from `mvp-build/ios-app/FootwearIntelligence/`
- [ ] confirm all files are included in the app target
- [ ] add HealthKit capability
- [ ] add `NSHealthShareUsageDescription`
- [ ] set backend URL if needed for simulator/device (`FOOTWEAR_BACKEND_URL` supported)
- [ ] boot app to loading state
- [ ] confirm session bootstrap resolves cleanly or fails clearly
- [ ] confirm onboarding path works
- [ ] confirm footwear list/detail path builds
- [ ] confirm Assign / Home / Insights / Settings build
- [ ] build app successfully
- [ ] launch app successfully

## First end-to-end app flow
- [ ] bootstrap user
- [ ] complete onboarding
- [ ] add first footwear
- [ ] import demo data or HealthKit data
- [ ] assign unassigned wear
- [ ] log condition
- [ ] verify Home updates
- [ ] verify Insights updates

## What counts as first solid testing point
- backend running against a real database
- app builds in Xcode
- app launches successfully
- the main prototype loop can be exercised without immediate collapse
