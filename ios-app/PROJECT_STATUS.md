# iOS Project Status

## Current state
The iOS side currently exists as a **structured SwiftUI source tree**, not yet as a checked-in `.xcodeproj` or `.xcworkspace`.

## What exists now
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

## What does not yet exist
- actual Xcode project container
- target membership wiring
- signing/capabilities setup in a real target
- real plist wiring in a built target
- proof of successful compile in Xcode

## Honest interpretation
This is past the idea stage and past raw planning, but still short of a real testable Apple build.

## Immediate next target
Get the source tree into a real Xcode app target and remove obvious compile/handoff confusion before Mac-side testing.
