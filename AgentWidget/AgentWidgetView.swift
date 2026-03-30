import SwiftUI
import WidgetKit

// ── Top-level widget view — dispatches to size-specific layouts ────────────

struct AgentWidgetView: View {
    let data: PipelineData
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:  SmallWidgetView(data: data)
        case .systemMedium: MediumWidgetView(data: data)
        case .systemLarge:  LargeWidgetView(data: data)
        default:            MediumWidgetView(data: data)
        }
    }
}

// ── Small ──────────────────────────────────────────────────────────────────

struct SmallWidgetView: View {
    let data: PipelineData

    private var overallProgress: Double {
        let statuses = AgentID.allCases.map { data.status(for: $0) }
        return statuses.map(\.progress).reduce(0, +) / Double(AgentID.allCases.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Label("Agent Office", systemImage: "person.3.fill")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)

            Spacer()

            // Orchestrator
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(orchAccent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("오케스트레이터")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(data.orchMessage)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            // Overall progress
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.15)).frame(height: 4)
                    Capsule()
                        .fill(data.orchState == .done ? Color.green : Color.accentColor)
                        .frame(width: g.size.width * overallProgress, height: 4)
                }
            }
            .frame(height: 4)

            // Log
            Text(data.logMessage)
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(.tertiary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(14)
    }

    private var orchAccent: Color {
        switch data.orchState {
        case .idle:    return Color.secondary
        case .working: return Color.accentColor
        case .done:    return Color.green
        }
    }
}

// ── Medium ─────────────────────────────────────────────────────────────────

struct MediumWidgetView: View {
    let data: PipelineData

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: 6) {
                Label("Agent Office", systemImage: "person.3.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if data.isRunning {
                    Label("실행 중", systemImage: "circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                } else if data.orchState == .done {
                    Label("완료", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(Color.green)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 6)

            // Orchestrator message
            HStack(spacing: 6) {
                Image(systemName: "target")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(orchAccent)
                Text(data.orchMessage)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 8)

            Divider().padding(.horizontal, 14)

            // 5 agent cells
            HStack(spacing: 0) {
                ForEach(AgentID.allCases, id: \.self) { id in
                    MediumAgentCell(id: id, status: data.status(for: id))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)

            // Log
            Text(data.logMessage)
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(.tertiary)
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.horizontal, 14)
                .padding(.bottom, 10)
        }
    }

    private var orchAccent: Color {
        switch data.orchState {
        case .idle:    return .secondary
        case .working: return .accentColor
        case .done:    return .green
        }
    }
}

private struct MediumAgentCell: View {
    let id: AgentID
    let status: AgentStatus

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(cellBg)
                    .frame(width: 28, height: 28)
                Image(systemName: id.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(id.title)
                .font(.system(size: 7.5, weight: .semibold))
                .foregroundStyle(status.state == .idle ? Color.secondary : Color.primary)

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.15)).frame(height: 2)
                    Capsule()
                        .fill(status.state == .done ? Color.green : id.color)
                        .frame(width: g.size.width * status.progress, height: 2)
                }
            }
            .frame(height: 2)

            if status.state == .working {
                Circle().fill(id.color).frame(width: 4, height: 4)
            } else if status.state == .done {
                Image(systemName: "checkmark").font(.system(size: 6, weight: .bold)).foregroundStyle(.green)
            } else {
                Color.clear.frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .opacity(status.state == .idle ? 0.45 : 1.0)
    }

    private var cellBg: Color {
        switch status.state {
        case .idle:    return Color.secondary.opacity(0.1)
        case .working: return id.color.opacity(0.15)
        case .done:    return Color.green.opacity(0.12)
        }
    }
    private var iconColor: Color {
        switch status.state {
        case .idle:    return .secondary
        case .working: return id.color
        case .done:    return .green
        }
    }
}

// ── Large ──────────────────────────────────────────────────────────────────

struct LargeWidgetView: View {
    let data: PipelineData

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label("Agent Office", systemImage: "person.3.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            // Orchestrator row
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(orchBg)
                        .frame(width: 30, height: 30)
                    Image(systemName: "target")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(orchAccent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("오케스트레이터")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(data.orchMessage)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if data.orchState == .done {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(orchRowBg)
            )
            .padding(.horizontal, 14)
            .padding(.bottom, 8)

            Divider().padding(.horizontal, 14).padding(.bottom, 6)

            // Agent rows
            ForEach(AgentID.allCases, id: \.self) { id in
                LargeAgentRow(id: id, status: data.status(for: id))
            }

            Spacer()

            Divider()
            // Log footer
            HStack(spacing: 6) {
                Capsule()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 2, height: 12)
                Text(data.logMessage)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
    }

    private var orchAccent: Color {
        switch data.orchState {
        case .idle:    return .secondary
        case .working: return .accentColor
        case .done:    return .green
        }
    }
    private var orchBg: Color {
        switch data.orchState {
        case .idle:    return Color.secondary.opacity(0.1)
        case .working: return Color.accentColor.opacity(0.12)
        case .done:    return Color.green.opacity(0.12)
        }
    }
    private var orchRowBg: Color {
        data.orchState == .working
            ? Color.accentColor.opacity(0.06)
            : Color.secondary.opacity(0.05)
    }
}

private struct LargeAgentRow: View {
    let id: AgentID
    let status: AgentStatus

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(cellBg).frame(width: 26, height: 26)
                Image(systemName: id.icon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(id.title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(status.state == .idle ? Color.secondary : Color.primary)
                .frame(width: 36, alignment: .leading)

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.15)).frame(height: 3)
                    Capsule()
                        .fill(status.state == .done ? Color.green : id.color)
                        .frame(width: g.size.width * status.progress, height: 3)
                }
            }
            .frame(height: 3)

            Group {
                if status.state == .working {
                    Text("실행 중")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(id.color)
                } else if status.state == .done {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.green)
                } else {
                    Text("대기")
                        .font(.system(size: 8))
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(width: 40, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 5)
        .opacity(status.state == .idle ? 0.5 : 1.0)
    }

    private var cellBg: Color {
        switch status.state {
        case .idle:    return Color.secondary.opacity(0.08)
        case .working: return id.color.opacity(0.15)
        case .done:    return Color.green.opacity(0.12)
        }
    }
    private var iconColor: Color {
        switch status.state {
        case .idle:    return .secondary
        case .working: return id.color
        case .done:    return .green
        }
    }
}
