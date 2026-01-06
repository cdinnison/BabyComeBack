// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ClaudeStatusBar",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "ClaudeStatusBar",
            path: "Sources",
            sources: ["main.swift"]
        ),
        .executableTarget(
            name: "claude-status-notify",
            path: "Sources",
            sources: ["notify.swift"]
        )
    ]
)
