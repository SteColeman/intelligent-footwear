# Xcode Run Setup

## Goal
Turn the current SwiftUI source tree into a runnable local iOS prototype in Xcode.

## Current state
A checked-in Xcode project now exists in the repo and has already had real Mac-side build/run work.

Project container:
- `ios-app/FootwearIntelligence/Footwear Intelligence.xcodeproj`

See also:
- `PROJECT_STATUS.md`
- `XCODE_PROJECT_BLUEPRINT.md`
- `MAC_HANDOFF_CHECKLIST.md`

## Steps

### 1. Open the checked-in iOS app project in Xcode
Open:
- `ios-app/FootwearIntelligence/Footwear Intelligence.xcodeproj`

### 2. Verify source membership instead of rebuilding project structure
Use the existing checked-in source tree and confirm newer files are included in the target, especially:
- `Core/Photos/FootwearPhotoStore.swift`
- `Core/UI/FootwearPhotoView.swift`
- `Core/Models/UpdateFootwearRequest.swift`
- `Core/ViewModels/EditFootwearViewModel.swift`
- `Features/Footwear/EditFootwearView.swift`

### 3. Add HealthKit capability
In Signing & Capabilities:
- add `HealthKit`

### 4. Add Info.plist privacy string
Add:
- `NSHealthShareUsageDescription`

Recommended value:
`We use Apple Health data like steps, distance, and walking or hiking activity to help track real-life footwear wear.`

### 5. Configure backend URL
Default prototype backend URL:
- `http://localhost:3000`

The app also supports an environment override:
- `FOOTWEAR_BACKEND_URL`

Use that for:
- Mac simulator pointing at LAN/hosted backend
- physical iPhone pointing at hosted backend

For hosted-device testing, prefer a real hosted URL instead of LAN-only assumptions.
See also:
- `../HOSTED_RUNTIME_SWITCHOVER_CHECKLIST.md`
- `../HOSTED_BACKEND_DEPLOYMENT_PLAN.md`

### 6. Run backend first
Use the backend README instructions before launching the app.

### 7. Recommended Xcode verification order
After files are added to the target, verify in this order:
1. app boots to loading state
2. session bootstrap resolves or shows clear boot error
3. onboarding navigation works
4. footwear list/build path works
5. footwear detail screen compiles and opens
6. Assign screen compiles and loads
7. Home / Insights / Settings compile and open
8. HealthKit permission flow behaves sensibly

### 8. First test path
- boot app
- onboarding
- connect Apple Health or skip
- add first footwear
- import demo data or today’s health data
- assign wear
- log condition
- review Home / Insights

## Important current limitation
This is still a prototype path, not a polished release-grade app packaging setup.

## Solid testing point for Mac handoff
The real handoff milestone is:
- backend running against a real DB
- Xcode target created and wired
- app launches and can exercise the main prototype loop
