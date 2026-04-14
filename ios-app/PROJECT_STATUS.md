# iOS Project Status

## Current state
The iOS side is now a **working checked-in Xcode project** with a substantially more real SwiftUI prototype than the earlier scaffold stage.

## What exists now
- working `.xcodeproj` checked into the repo
- app entry and root navigation
- boot/loading/error state handling
- session bootstrap logic
- API client with explicit HTTP error handling
- backend URL override support via `FOOTWEAR_BACKEND_URL`
- models and view models
- onboarding flow using `NavigationStack`
- Home / Footwear / Assign / Insights / Settings views
- footwear list → detail navigation path
- condition-history loading path in footwear detail
- cleaner assign/import/unassigned-wear flow structure
- HealthKit query scaffolding
- shared warm-surface UI primitives (`WarmHeroCard`, `WarmSurfaceCard`, `WarmSectionHeader`, `WarmHeroStat`, etc.)
- stronger visual treatment across the main product surfaces
- onboarding persistence path now writes back to backend instead of only local state
- primary footwear photo support in the prototype:
  - add photo during create flow
  - local photo preview
  - local photo persistence in app sandbox
  - list/detail rendering
  - change/remove photo from detail

## What still does not yet exist
- proof of stable end-to-end runtime across repeated test passes
- final cleaned Xcode/project folder structure
- true media upload/storage beyond local prototype persistence
- fully hardened photo/runtime UX on real device across repeated sessions
- fully completed runtime hardening for repeated onboarding/import/assign/detail cycles

## Honest interpretation
This is well past a source-only Apple prototype. It is now a buildable Xcode-backed connected prototype with a materially stronger UI system, a working onboarding persistence path, and real object-identity features like editable footwear photos.

It is still not a fully validated MVP.

## Immediate next target
Keep validating the real runtime loop on Mac/device, especially:
- repeated app relaunch behavior
- onboarding persistence
- photo add/change/remove behavior
- list/detail consistency after image updates
- import/assign/detail flows after repeated use
