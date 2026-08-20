// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LaunchCorner",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "LaunchCorner", targets: ["LaunchCorner"]) // if used as an app target in SPM
    ],
    dependencies: [
        // Official Sparkle repository URL
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "LaunchCorner",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: ".",
            exclude: [
                "LaunchCorner.xcodeproj", // Exclude Xcode project files when building with SPM
                ".git",
                ".github"
            ],
            sources: [
                "UpdateManager.swift",
                "PermissionManager.swift",
                "LaunchCornerApp.swift",
                "CornerConfig.swift",
                "ActionExecutor.swift"
            ]
        )
    ]
)
