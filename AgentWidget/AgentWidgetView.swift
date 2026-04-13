import SwiftUI
import WidgetKit

// ── Top-level widget view ──────────────────────────────────────────────────

struct AgentWidgetView: View {
    let data: PipelineData
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:      SmallWidgetView(data: data)
        case .systemMedium:     MediumWidgetView(data: data)
        case .systemLarge:      LargeWidgetView(data: data)
        case .systemExtraLarge: ExtraLargeWidgetView(data: data)
        default:                MediumWidgetView(data: data)
        }
    }
}

// ── Small ──────────────────────────────────────────────────────────────────

struct SmallWidgetView: View {
    let data: PipelineData

    private var activeAgent: (AgentID, AgentStatus)? {
        AgentID.allCases.compactMap { id -> (AgentID, AgentStatus)? in
            let s = data.status(for: id)
            return s.state == .working ? (id, s) : nil
        }.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text("Agent Office")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                statusDot
            }

            Spacer()

            if let (id, status) = activeAgent {
                // 활성 에이전트 강조
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: id.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(id.color)
                        Text(id.title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                    Text(status.message)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    ProgressView(value: status.progress)
                        .tint(id.color)
                        .scaleEffect(x: 1, y: 0.7)
                }
            } else {
                // 대기 상태
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.orchState == .done ? "완료" : "대기 중")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(data.orchState == .done ? Color.green : Color.secondary)
                    Text(data.orchMessage)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            // 5개 에이전트 미니 도트
            HStack(spacing: 5) {
                ForEach(AgentID.allCases, id: \.self) { id in
                    let s = data.status(for: id)
                    Circle()
                        .fill(dotColor(for: id, state: s.state))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding(14)
    }

    private var statusDot: some View {
        Circle()
            .fill(data.isRunning ? Color.accentColor : (data.orchState == .done ? Color.green : Color.secondary.opacity(0.3)))
            .frame(width: 6, height: 6)
    }

    private func dotColor(for id: AgentID, state: AgentState) -> Color {
        switch state {
        case .idle:    return Color.secondary.opacity(0.2)
        case .working: return id.color
        case .done:    return Color.green.opacity(0.7)
        }
    }
}

// ── Medium ─────────────────────────────────────────────────────────────────

struct MediumWidgetView: View {
    let data: PipelineData

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text("Agent Office")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                statusBadge
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // 5 agent cells
            HStack(spacing: 6) {
                ForEach(AgentID.allCases, id: \.self) { id in
                    MediumAgentCell(id: id, status: data.status(for: id))
                }
            }
            .padding(.horizontal, 10)

            Spacer()

            // Log footer
            Text(data.logMessage)
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.horizontal, 14)
                .padding(.bottom, 10)
        }
    }

    private var statusBadge: some View {
        Group {
            if data.isRunning {
                HStack(spacing: 3) {
                    Circle().fill(Color.accentColor).frame(width: 5, height: 5)
                    Text("실행 중").font(.system(size: 8, weight: .semibold)).foregroundStyle(.accentColor)
                }
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Capsule().fill(Color.accentColor.opacity(0.1)))
            } else if data.orchState == .done {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark").font(.system(size: 7, weight: .bold)).foregroundStyle(.green)
                    Text("완료").font(.system(size: 8, weight: .semibold)).foregroundStyle(.green)
                }
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Capsule().fill(Color.green.opacity(0.1)))
            }
        }
    }
}

private struct MediumAgentCell: View {
    let id: AgentID
    let status: AgentStatus

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(cellBg)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle().stroke(status.state == .working ? id.color.opacity(0.6) : Color.clear, lineWidth: 1.5)
                    )
                Image(systemName: id.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(id.title)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(status.state == .idle ? Color.secondary : Color.primary)

            // 상태 표시
            if status.state == .working {
                Capsule()
                    .fill(id.color)
                    .frame(width: 24, height: 3)
            } else if status.state == .done {
                Image(systemName: "checkmark")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(.green)
            } else {
                Capsule()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: 24, height: 3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(status.state == .working ? id.color.opacity(0.08) : Color.clear)
        )
        .opacity(status.state == .idle ? 0.4 : 1.0)
    }

    private var cellBg: Color {
        switch status.state {
        case .idle:    return Color.secondary.opacity(0.08)
        case .working: return id.color.opacity(0.18)
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
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("Agent Office")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                    Text(data.orchMessage)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                orchStatusIcon
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 14).padding(.bottom, 6)

            // Agent rows
            ForEach(AgentID.allCases, id: \.self) { id in
                LargeAgentRow(id: id, status: data.status(for: id))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
            }

            Spacer()

            // Log footer
            Divider().padding(.horizontal, 14)
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 2, height: 10)
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

    private var orchStatusIcon: some View {
        Group {
            if data.isRunning {
                ZStack {
                    Circle().fill(Color.accentColor.opacity(0.15)).frame(width: 28, height: 28)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.accentColor)
                }
            } else if data.orchState == .done {
                ZStack {
                    Circle().fill(Color.green.opacity(0.15)).frame(width: 28, height: 28)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.green)
                }
            } else {
                ZStack {
                    Circle().fill(Color.secondary.opacity(0.08)).frame(width: 28, height: 28)
                    Image(systemName: "moon.zzz")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct LargeAgentRow: View {
    let id: AgentID
    let status: AgentStatus

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(cellBg)
                    .frame(width: 30, height: 30)
                Image(systemName: id.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(id.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(status.state == .idle ? Color.secondary : Color.primary)
                if status.state == .working, !status.message.isEmpty {
                    Text(status.message)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if status.state == .working {
                HStack(spacing: 4) {
                    ProgressView(value: status.progress)
                        .tint(id.color)
                        .frame(width: 50)
                        .scaleEffect(x: 1, y: 0.8)
                    Text("\(Int(status.progress * 100))%")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(id.color)
                        .frame(width: 28, alignment: .trailing)
                }
            } else if status.state == .done {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
            } else {
                Text("대기")
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(status.state == .working ? id.color.opacity(0.07) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(status.state == .working ? id.color.opacity(0.25) : Color.clear, lineWidth: 1)
                )
        )
        .opacity(status.state == .idle ? 0.45 : 1.0)
    }

    private var cellBg: Color {
        switch status.state {
        case .idle:    return Color.secondary.opacity(0.08)
        case .working: return id.color.opacity(0.18)
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

// ── Extra Large (세로 최대 활용) ────────────────────────────────────────────

struct ExtraLargeWidgetView: View {
    let data: PipelineData

    var body: some View {
        HStack(spacing: 0) {
            // 왼쪽: 오케스트레이터 + 상태
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text("Agent Office")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(.top, 4)

                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Text("오케스트레이터")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text(data.orchMessage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                }

                Spacer()

                // 로그
                VStack(alignment: .leading, spacing: 4) {
                    Text("최근 로그")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.tertiary)
                    Text(data.logMessage)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)

            Divider().padding(.vertical, 12)

            // 오른쪽: 에이전트 5개 세로 리스트
            VStack(spacing: 4) {
                ForEach(AgentID.allCases, id: \.self) { id in
                    ExtraLargeAgentRow(id: id, status: data.status(for: id))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct ExtraLargeAgentRow: View {
    let id: AgentID
    let status: AgentStatus

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(cellBg)
                    .frame(width: 36, height: 36)
                Image(systemName: id.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(id.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(status.state == .idle ? Color.secondary : Color.primary)
                if status.state == .working, !status.message.isEmpty {
                    Text(status.message)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else if status.state == .done {
                    Text("완료")
                        .font(.system(size: 10))
                        .foregroundStyle(.green)
                } else {
                    Text("대기 중")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            if status.state == .working {
                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(Int(status.progress * 100))%")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(id.color)
                    ProgressView(value: status.progress)
                        .tint(id.color)
                        .frame(width: 60)
                        .scaleEffect(x: 1, y: 0.8)
                }
            } else if status.state == .done {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.green)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(status.state == .working ? id.color.opacity(0.08) : Color.secondary.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(status.state == .working ? id.color.opacity(0.3) : Color.clear, lineWidth: 1.5)
                )
        )
        .opacity(status.state == .idle ? 0.4 : 1.0)
    }

    private var cellBg: Color {
        switch status.state {
        case .idle:    return Color.secondary.opacity(0.08)
        case .working: return id.color.opacity(0.18)
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
