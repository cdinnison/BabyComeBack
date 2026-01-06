// Simple CLI tool to post distributed notifications
// Usage: claude-status-notify [needs-attention|resumed] [session-id] [message]

import Foundation

func postNotification(name: String, sessionId: String, message: String) {
    let center = DistributedNotificationCenter.default()
    center.postNotificationName(
        NSNotification.Name(name),
        object: nil,
        userInfo: ["sessionId": sessionId, "message": message],
        deliverImmediately: true
    )
}

let args = CommandLine.arguments
guard args.count >= 2 else {
    fputs("Usage: claude-status-notify [needs-attention|resumed] [session-id] [message]\n", stderr)
    exit(1)
}

let action = args[1]
let sessionId = args.count > 2 ? args[2] : "default"
let message = args.count > 3 ? args[3] : ""

switch action {
case "needs-attention":
    postNotification(name: "com.claude.needsAttention", sessionId: sessionId, message: message)
case "resumed":
    postNotification(name: "com.claude.resumed", sessionId: sessionId, message: message)
default:
    fputs("Unknown action: \(action). Use 'needs-attention' or 'resumed'\n", stderr)
    exit(1)
}
