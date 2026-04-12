import SwiftUI

@main
struct FootwearIntelligenceApp: App {
    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
            Group {
                if session.isBootstrapping {
                    BootStatusView(
                        title: "Loading",
                        message: "Setting up your footwear session…",
                        actionTitle: nil,
                        action: nil
                    )
                } else if let error = session.bootstrapError {
                    BootStatusView(
                        title: "Boot failed",
                        message: error,
                        actionTitle: "Retry",
                        action: {
                            Task {
                                await session.bootstrap()
                            }
                        }
                    )
                } else if session.userId == nil {
                    BootStatusView(
                        title: "No user session",
                        message: "The app could not resolve a backend user. Check backend bootstrapping and try again.",
                        actionTitle: "Retry",
                        action: {
                            Task {
                                await session.bootstrap()
                            }
                        }
                    )
                } else if session.hasCompletedOnboarding {
                    RootTabView()
                        .environmentObject(session)
                } else {
                    WelcomeView()
                        .environmentObject(session)
                }
            }
            .task {
                await session.bootstrap()
            }
        }
    }
}
