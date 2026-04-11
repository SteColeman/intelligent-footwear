# FootwearIntelligence iOS Prototype

## Current state
This folder contains the SwiftUI source structure for the prototype.

Implemented so far:
- app session bootstrap
- onboarding flow using `NavigationStack`
- Apple Health permission prompt
- Home / Footwear / Assign / Insights / Settings tabs
- backend API client with explicit HTTP error handling
- create footwear flow
- assignment flow
- cleaner import/unassigned-wear structure in Assign
- condition check-in flow
- footwear list → detail path
- footwear detail lifecycle + condition-history loading path
- slightly more informative onboarding and settings flows
- HealthKit service scaffold
- real today step + walking/running distance query structure
- relevant workout import structure for walking/hiking/running
- shared display-name handling for footwear UI

## Current boot assumption
The app bootstraps a prototype backend user via:
- authProviderId: `demo-user`
- backend `/dev/bootstrap-demo-user`

## Backend config
Default backend expectation:
- `http://localhost:3000`

Override supported via environment:
- `FOOTWEAR_BACKEND_URL`

## Not yet complete
- full Xcode project container
- Info.plist setup in an actual target
- HealthKit entitlement wiring in an actual target
- production auth
- proof of successful compile in Xcode

## Next implementation target
Wrap this source into a proper Xcode-runnable app target and validate the end-to-end prototype loop.
