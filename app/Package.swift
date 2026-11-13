// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Interference",
    platforms: [.iOS(.v26)],
    products: [.library(name: "Interference", targets: ["Interference"])],
    targets: [
        .target(
            name: "Interference",
            swiftSettings: [
                .defaultIsolation(MainActor.self),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .treatAllWarnings(as: .error),
            ]
        )
    ]
)
