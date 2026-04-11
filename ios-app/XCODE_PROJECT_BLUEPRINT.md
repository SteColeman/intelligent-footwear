# Xcode Project Blueprint

## Intended project
- App name: `FootwearIntelligence`
- Platform: iOS
- Interface: SwiftUI
- Language: Swift
- Minimum target: choose a modern iOS version supported by HealthKit and SwiftUI in current Xcode

## Recommended group structure
- `App`
- `Core`
- `Features`
- `Resources`

## Source root to import
Use this folder as the source of truth:
- `mvp-build/ios-app/FootwearIntelligence/`

## Files that should be added to the app target
### App
- `App/BootStatusView.swift`
- `App/FootwearIntelligenceApp.swift`
- `App/RootTabView.swift`

### Core
- `Core/AppSession.swift`
- `Core/Config/AppConfig.swift`
- `Core/Health/HealthImportModels.swift`
- `Core/Health/HealthImportService.swift`
- `Core/Health/HealthKitService.swift`
- `Core/Models/AssignmentRequest.swift`
- `Core/Models/CreateFootwearRequest.swift`
- `Core/Models/FootwearItem.swift`
- `Core/Models/HomeSummary.swift`
- `Core/Models/InsightSummary.swift`
- `Core/Models/UserProfile.swift`
- `Core/Models/WearEvent.swift`
- `Core/Networking/APIClient.swift`
- `Core/ViewModels/AssignViewModel.swift`
- `Core/ViewModels/ConditionCheckInViewModel.swift`
- `Core/ViewModels/CreateFootwearViewModel.swift`
- `Core/ViewModels/FootwearDetailViewModel.swift`
- `Core/ViewModels/FootwearListViewModel.swift`
- `Core/ViewModels/HomeViewModel.swift`
- `Core/ViewModels/InsightsViewModel.swift`

### Features
- `Features/Assign/AssignView.swift`
- `Features/Condition/ConditionCheckInView.swift`
- `Features/Footwear/CreateFootwearView.swift`
- `Features/Footwear/FootwearDetailView.swift`
- `Features/Footwear/FootwearListView.swift`
- `Features/Home/HomeView.swift`
- `Features/Insights/InsightsView.swift`
- `Features/Onboarding/FirstFootwearPromptView.swift`
- `Features/Onboarding/HealthPermissionView.swift`
- `Features/Onboarding/WelcomeView.swift`
- `Features/Settings/SettingsView.swift`

## Capabilities required
- HealthKit

## Info.plist entries required
- `NSHealthShareUsageDescription`

Suggested value:
`We use Apple Health data like steps, distance, and walking or hiking activity to help track real-life footwear wear.`

## Backend config note
Default backend expectation is localhost-style development.
The app also supports an override via:
- `FOOTWEAR_BACKEND_URL`

## Current app-surface expectation after target wiring
Once the files are correctly added to the target, the app should be able to:
- boot into loading / error / resolved session state
- navigate onboarding
- add footwear
- browse footwear list/detail
- run assign/import flow
- open Home / Insights / Settings

## First Mac-side validation goal
Reach a state where the app:
1. launches
2. resolves bootstrap session
3. shows onboarding or tabs without compile errors
4. can hit a working backend
