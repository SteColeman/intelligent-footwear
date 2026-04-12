# These Boots Are Made for Walkin — MVP Build

This folder contains the current implementation scaffold for the footwear intelligence MVP.

## Stack
- iOS app: SwiftUI
- Backend: TypeScript + Fastify
- Database: PostgreSQL
- ORM/schema: Prisma

## Structure
- `backend/` — API, schema, lifecycle logic
- `ios-app/` — SwiftUI app structure
- `shared/` — shared contracts/docs later if needed
- `docs/` — implementation-specific docs copied or added later

## Current honest state
This is a **connected prototype** moving toward a real test build.

What exists now:
- backend route scaffold with validation/error-handling work
- Prisma schema and seed path
- SwiftUI source tree for onboarding, Home, Footwear, Assign, Insights, Settings
- HealthKit query/import scaffolding
- Mac/Xcode handoff docs
- initial UI direction guidance based on market/design research

What does **not** exist yet:
- validated DB-backed backend run in this Linux environment
- fully hardened repeated runtime validation
- final cleaned Xcode/repo structure

## Current nearest milestone
Reach a **solid testing point** where:
1. backend runs against a real PostgreSQL instance
2. backend smoke path passes
3. SwiftUI/Xcode runtime holds up across repeated use
4. the prototype loop is stable enough for ongoing MVP hardening

## Key docs
- `HANDOFF_READINESS.md`
- `MOVE_TO_MAC_THRESHOLD.md`
- `FIRST_REPO_BOOTSTRAP.md`
- `UI_DIRECTION_SUMMARY.md`
- `VALIDATION_STATUS.md`
- `PROTOTYPE_SANITY_CHECKLIST.md`
- `RUN_PROTOTYPE.md`
- `END_TO_END_VALIDATION_NOTES.md`
- `REPO_STATUS.md`
- `backend/README.md`
- `ios-app/XCODE_RUN_SETUP.md`
- `ios-app/MAC_HANDOFF_CHECKLIST.md`
