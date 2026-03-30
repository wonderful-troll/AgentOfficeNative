import SwiftUI
import WidgetKit

// ── Pipeline steps definition ──────────────────────────────────────────────

enum PipelineStep {
    case orch(message: String, duration: Double)
    case agent(AgentID, message: String, duration: Double)
    case parallel([AgentID], messages: [String], duration: Double)
    case showResults([String])
}

let defaultSteps: [PipelineStep] = [
    .orch(message: "작업 분석 중...", duration: 1.2),
    .agent(.research, message: "시장 데이터 수집 중", duration: 2.5),
    .orch(message: "리서치 완료 → 기획 시작", duration: 0.6),
    .agent(.planner, message: "전략 기획서 작성 중", duration: 2.2),
    .orch(message: "기획 완료 → 병렬 검토 시작", duration: 0.6),
    .parallel([.creative, .security],
              messages: ["창의적 대안 탐색 중", "보안 리스크 스캔 중"],
              duration: 2.8),
    .orch(message: "병렬 작업 완료 → 최종 검토", duration: 0.6),
    .agent(.reviewer, message: "통합 리뷰 작성 중", duration: 2.0),
    .orch(message: "모든 에이전트 작업 완료 ✓", duration: 0.8),
    .showResults(["리서치 리포트 완성", "기획서 v1.0 완성", "창의 대안 3가지", "보안 감사 통과", "최종 리뷰 완성"]),
]

// ── ViewModel ─────────────────────────────────────────────────────────────

@MainActor
class PipelineViewModel: ObservableObject {
    @Published var pipeline: PipelineData = SharedDataStore.load()

    var isRunning: Bool { pipeline.isRunning }

    // Watches for changes written by update_widget.sh
    private var fileWatchTimer: Timer?
    private var lastModDate: Date?

    init() {
        startFileWatcher()
    }

    // Poll the JSON file every 1.5 s AND listen for Darwin instant notifications
    func startFileWatcher() {
        lastModDate = SharedDataStore.statusFileModificationDate()

        // Darwin notification — fired by update_widget.sh for instant updates
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterAddObserver(
            center, Unmanaged.passUnretained(self).toOpaque(),
            { _, observer, _, _, _ in
                guard let ptr = observer else { return }
                let vm = Unmanaged<PipelineViewModel>.fromOpaque(ptr).takeUnretainedValue()
                Task { @MainActor in vm.checkForExternalUpdate() }
            },
            "com.agentoffice.update" as CFString,
            nil, .deliverImmediately
        )

        // Polling fallback (handles race conditions)
        fileWatchTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.checkForExternalUpdate() }
        }
    }

    private func checkForExternalUpdate() {
        let mod = SharedDataStore.statusFileModificationDate()
        guard let mod, mod != lastModDate else { return }
        lastModDate = mod
        let updated = SharedDataStore.load()
        pipeline = updated
        // Write back to UserDefaults so the widget extension can read it
        SharedDataStore.save(updated)   // also calls reloadAllTimelines()
    }

    func run() {
        guard !isRunning else { return }
        Task { await executePipeline() }
    }

    func reset() {
        pipeline = PipelineData()
        SharedDataStore.save(pipeline)
    }

    private func executePipeline() async {
        pipeline.isRunning = true
        pipeline.orchState = .idle
        pipeline.orchMessage = "대기 중"
        pipeline.results = []
        for id in AgentID.allCases {
            pipeline.agentStatuses[id.rawValue] = AgentStatus()
        }
        save()

        for step in defaultSteps {
            switch step {
            case .orch(let msg, let dur):
                pipeline.orchState = .working
                pipeline.orchMessage = msg
                pipeline.logMessage = "⚡ 오케스트레이터: \(msg)"
                save()
                await animateOrch(duration: dur)

            case .agent(let id, let msg, let dur):
                pipeline.agentStatuses[id.rawValue] = AgentStatus(state: .working, message: msg, progress: 0)
                pipeline.logMessage = "▶ \(id.title): \(msg)"
                save()
                await animateProgress(id: id, duration: dur)
                pipeline.agentStatuses[id.rawValue] = AgentStatus(state: .done, message: "완료", progress: 1.0)
                save()

            case .parallel(let ids, let messages, let dur):
                for (i, id) in ids.enumerated() {
                    let msg = i < messages.count ? messages[i] : "처리 중"
                    pipeline.agentStatuses[id.rawValue] = AgentStatus(state: .working, message: msg, progress: 0)
                }
                pipeline.logMessage = "⚡ 병렬 실행: \(ids.map(\.title).joined(separator: " + "))"
                save()
                await animateParallel(ids: ids, duration: dur)
                for id in ids {
                    pipeline.agentStatuses[id.rawValue] = AgentStatus(state: .done, message: "완료", progress: 1.0)
                }
                save()

            case .showResults(let results):
                pipeline.results = results
                pipeline.orchState = .done
                pipeline.isRunning = false
                pipeline.logMessage = "✅ 파이프라인 완료"
                save()
            }
        }
    }

    private func animateOrch(duration: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }

    private func animateProgress(id: AgentID, duration: Double) async {
        let steps = 20
        let interval = duration / Double(steps)
        for i in 1...steps {
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            pipeline.agentStatuses[id.rawValue]?.progress = Double(i) / Double(steps)
            save()
        }
    }

    private func animateParallel(ids: [AgentID], duration: Double) async {
        let steps = 20
        let interval = duration / Double(steps)
        for i in 1...steps {
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            let p = Double(i) / Double(steps)
            for id in ids {
                pipeline.agentStatuses[id.rawValue]?.progress = p
            }
            save()
        }
    }

    private func save() {
        pipeline.lastUpdated = Date()
        SharedDataStore.save(pipeline)
        objectWillChange.send()
    }
}

// ── ContentView ────────────────────────────────────────────────────────────

struct ContentView: View {
    @StateObject private var vm = PipelineViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()
            agentPanel
            Divider()
            logFooter
            if !vm.pipeline.results.isEmpty {
                resultStrip
            }
        }
    }

    // ── Header ───────────────────────────────────────────────────────────

    private var headerBar: some View {
        HStack(spacing: 8) {
            Label("Agent Office", systemImage: "person.3.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)

            Spacer()

            Text("데스크탑 우클릭 → 위젯 편집")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)

            Button {
                withAnimation { vm.reset() }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 12, weight: .semibold))
            }
            .buttonStyle(.borderless)
            .disabled(vm.isRunning)

            Button { vm.run() } label: {
                HStack(spacing: 5) {
                    if vm.isRunning {
                        ProgressView().scaleEffect(0.6).frame(width: 12, height: 12)
                    } else {
                        Image(systemName: "play.fill").font(.system(size: 10))
                    }
                    Text(vm.isRunning ? "실행 중" : "실행")
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(vm.isRunning)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // ── Agent panel ───────────────────────────────────────────────────────

    private var agentPanel: some View {
        VStack(spacing: 12) {
            // Orchestrator
            orchRow

            // Divider with arrow
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    Rectangle().fill(Color.secondary.opacity(0.25)).frame(width: 1, height: 10)
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                }
                Spacer()
            }

            // 5 agent cards
            HStack(spacing: 8) {
                ForEach(AgentID.allCases, id: \.self) { id in
                    AppAgentCard(id: id, status: vm.pipeline.status(for: id))
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
    }

    private var orchRow: some View {
        OrchRowView(state: vm.pipeline.orchState, message: vm.pipeline.orchMessage)
    }

    // ── Log footer ────────────────────────────────────────────────────────

    private var logFooter: some View {
        HStack(spacing: 6) {
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 2, height: 14)
            Text(vm.pipeline.logMessage)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.secondary.opacity(0.04))
    }

    // ── Result strip ──────────────────────────────────────────────────────

    private var resultStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(vm.pipeline.results.enumerated()), id: \.offset) { i, r in
                    Text(r)
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundStyle(i == vm.pipeline.results.count - 1 ? Color.green : Color.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(i == vm.pipeline.results.count - 1
                                           ? Color.green.opacity(0.12)
                                           : Color.secondary.opacity(0.08))
                        )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
        .background(Color.secondary.opacity(0.04))
    }
}

// ── Orchestrator row (extracted to avoid type-check timeout) ──────────────

private struct OrchRowView: View {
    let state: OrchState
    let message: String

    private var circleFill: Color {
        switch state {
        case .idle:    return Color.secondary.opacity(0.1)
        case .working: return Color.accentColor.opacity(0.15)
        case .done:    return Color.green.opacity(0.12)
        }
    }
    private var iconColor: Color {
        switch state {
        case .idle:    return .secondary
        case .working: return .accentColor
        case .done:    return .green
        }
    }
    private var msgColor: Color {
        switch state {
        case .idle:    return .secondary
        case .working: return .accentColor
        case .done:    return .green
        }
    }
    private var bgFill: Color {
        state == .working ? Color.accentColor.opacity(0.07) : Color.secondary.opacity(0.05)
    }
    private var borderColor: Color {
        switch state {
        case .idle:    return Color.secondary.opacity(0.12)
        case .working: return Color.accentColor.opacity(0.3)
        case .done:    return Color.green.opacity(0.25)
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(circleFill).frame(width: 32, height: 32)
                Image(systemName: "target")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("오케스트레이터")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(state == .idle ? Color.secondary : Color.primary)
                Text(message)
                    .font(.system(size: 9.5, design: .monospaced))
                    .foregroundStyle(msgColor)
            }
            Spacer()
            if state == .done {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.green).font(.system(size: 16))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 10).fill(bgFill))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderColor, lineWidth: 1))
        .padding(.horizontal, 16)
    }
}

// ── App agent card ─────────────────────────────────────────────────────────

struct AppAgentCard: View {
    let id: AgentID
    let status: AgentStatus

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(circleFill)
                    .frame(width: 36, height: 36)
                Image(systemName: id.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            Text(id.title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(status.state == .idle ? Color.secondary : Color.primary)

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.06)).frame(height: 2)
                    Capsule()
                        .fill(status.state == .done ? Color.green : id.color)
                        .frame(width: g.size.width * status.progress, height: 2)
                }
            }
            .frame(height: 2)

            stateLabel
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(cardBorder, lineWidth: 1)
        )
        .opacity(status.state == .idle ? 0.45 : 1.0)
    }

    @ViewBuilder
    private var stateLabel: some View {
        if status.state == .working {
            Text("실행 중")
                .font(.system(size: 7.5, weight: .bold))
                .foregroundStyle(id.color)
                .frame(height: 10)
        } else if status.state == .done {
            Image(systemName: "checkmark")
                .font(.system(size: 7.5, weight: .bold))
                .foregroundStyle(.green)
                .frame(height: 10)
        } else {
            Color.clear.frame(height: 10)
        }
    }

    private var circleFill: Color {
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
    private var cardBg: Color {
        switch status.state {
        case .idle:    return Color.secondary.opacity(0.05)
        case .working: return id.color.opacity(0.08)
        case .done:    return Color.green.opacity(0.07)
        }
    }
    private var cardBorder: Color {
        switch status.state {
        case .idle:    return Color.secondary.opacity(0.12)
        case .working: return id.color.opacity(0.4)
        case .done:    return Color.green.opacity(0.3)
        }
    }
}
