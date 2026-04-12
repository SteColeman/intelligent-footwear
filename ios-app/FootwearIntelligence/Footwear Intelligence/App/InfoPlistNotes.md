# Info.plist / Capability Notes

To run the iOS prototype properly in Xcode, add:

## Privacy usage string
- `NSHealthShareUsageDescription`

Recommended value:
`We use Apple Health data like steps, distance, and walking or hiking activity to help track real-life footwear wear.`

## Capabilities
Enable:
- HealthKit

## Backend config note
The app defaults to:
- `http://localhost:3000`

If simulator/device networking needs a different backend host, use the supported environment override:
- `FOOTWEAR_BACKEND_URL`

## Notes
The current source tree is meaningfully cleaner than the original scaffold, but it still needs to be wrapped into an actual Xcode project target with:
- app target
- bundle id
- Info.plist
- signing
- HealthKit capability
