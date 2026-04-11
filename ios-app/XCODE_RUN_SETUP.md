# Xcode Run Setup

## Goal
Turn the current SwiftUI source tree into a runnable local iOS prototype in Xcode.

## Current state
The source structure exists, but there is still **no checked-in `.xcodeproj` / target container** in this repo yet.

See also:
- `PROJECT_STATUS.md`
- `XCODE_PROJECT_BLUEPRINT.md`
- `MAC_HANDOFF_CHECKLIST.md`

## Steps

### 1. Create a new iOS app project in Xcode
- App name: `FootwearIntelligence`
- Interface: SwiftUI
- Language: Swift
- Use Core Data: No
- Include Tests: optional for now

### 2. Replace generated source with project source
Use the files from:
`mvp-build/ios-app/FootwearIntelligence/`

Map them into the Xcode project groups:
- App
- Core
- Features
- Resources

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

Use that if simulator/device networking requires a different host.

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
