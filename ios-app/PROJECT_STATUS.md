# iOS Project Status

## Current state
The iOS side now includes a **working checked-in Xcode project container** plus the structured SwiftUI source tree.

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
- less scaffold-y app copy across the main screens
- slightly more informative onboarding + settings paths
- HealthKit query scaffolding

## What still does not yet exist
- proof of stable end-to-end runtime across repeated test passes
- polished Xcode project layout
- final cleaned canonical iOS folder structure

## Honest interpretation
This is no longer just a source-only Apple prototype. It has crossed into a buildable Xcode-backed prototype, but still needs runtime hardening and some repo/Xcode structure cleanup.

## Immediate next target
Keep validating the real runtime loop, then clean the remaining Xcode/repo structure rough edges without breaking the working build.
