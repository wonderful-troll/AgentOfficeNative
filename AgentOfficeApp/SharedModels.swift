import SwiftUI

// ── Agent definitions ──────────────────────────────────────────────────────

enum AgentID: String, CaseIterable, Codable {
    case research, planner, creative, security, reviewer

    var title: String {
        switch self {
        case .research:  return "리서치"
        case .planner:   return "기획"
        case .creative:  return "창의"
        case .security:  return "보안"
        case .reviewer:  return "검토"
        }
    }

    var icon: String {
        switch self {
        case .research:  return "magnifyingglass"
        case .planner:   return "list.bullet.clipboard"
        case .creative:  return "lightbulb"
        case .security:  return "lock.shield"
        case .reviewer:  return "checkmark.seal"
        }
    }

    var color: Color {
        switch self {
        case .research:  return Color(red: 0.36, green: 0.72, blue: 1.0)
        case .planner:   return Color(red: 0.8,  green: 0.5,  blue: 1.0)
        case .creative:  return Color(red: 1.0,  green: 0.7,  blue: 0.2)
        case .security:  return Color(red: 1.0,  green: 0.4,  blue: 0.4)
        case .reviewer:  return Color(red: 0.3,  green: 0.9,  blue: 0.6)
        }
    }

    var colorHex: String {
        switch self {
        case .research:  return "#5CB8FF"
        case .planner:   return "#CC80FF"
        case .creative:  return "#FFB333"
        case .security:  return "#FF6666"
        case .reviewer:  return "#4DE699"
        }
    }
}

// ── Agent state ────────────────────────────────────────────────────────────

enum AgentState: String, Codable {
    case idle, working, done
}

struct AgentStatus: Codable {
    var state: AgentState = .idle
    var message: String = ""
    var progress: Double = 0
}

// ── Orchestrator state ─────────────────────────────────────────────────────

enum OrchState: String, Codable {
    case idle, working, done
}

// ── Pipeline data (shared between app and widget) ──────────────────────────

struct PipelineData: Codable {
    var orchState: OrchState = .idle
    var orchMessage: String = "대기 중"
    var agentStatuses: [String: AgentStatus] = [:]
    var logMessage: String = "준비 완료"
    var results: [String] = []
    var isRunning: Bool = false
    var lastUpdated: Date = Date()

    func status(for id: AgentID) -> AgentStatus {
        agentStatuses[id.rawValue] ?? AgentStatus()
    }
}
