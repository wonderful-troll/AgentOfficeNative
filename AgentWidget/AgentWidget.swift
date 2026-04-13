import WidgetKit
import SwiftUI
import AppIntents

// ── Timeline Entry ─────────────────────────────────────────────────────────

struct AgentEntry: TimelineEntry {
    let date: Date
    let data: PipelineData
}

// ── Timeline Provider ──────────────────────────────────────────────────────

struct AgentTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> AgentEntry {
        AgentEntry(date: Date(), data: placeholderData())
    }

    func getSnapshot(in context: Context, completion: @escaping (AgentEntry) -> Void) {
        let data = context.isPreview ? placeholderData() : SharedDataStore.load()
        completion(AgentEntry(date: Date(), data: data))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AgentEntry>) -> Void) {
        let data = SharedDataStore.load()
        let entry = AgentEntry(date: Date(), data: data)
        // Refresh every 5 minutes (or sooner when app calls reloadAllTimelines)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func placeholderData() -> PipelineData {
        var data = PipelineData()
        data.orchState = .working
        data.orchMessage = "에이전트 조율 중..."
        data.logMessage = "▶ research → 분석 중"
        data.agentStatuses["research"] = AgentStatus(state: .working, message: "시장 조사 중", progress: 0.6)
        data.agentStatuses["planner"]  = AgentStatus(state: .done,    message: "기획 완료",   progress: 1.0)
        data.agentStatuses["creative"] = AgentStatus(state: .idle,    message: "",            progress: 0)
        data.agentStatuses["security"] = AgentStatus(state: .idle,    message: "",            progress: 0)
        data.agentStatuses["reviewer"] = AgentStatus(state: .idle,    message: "",            progress: 0)
        return data
    }
}

// ── Widget Definition ──────────────────────────────────────────────────────

struct AgentOfficeWidget: Widget {
    let kind: String = "AgentOfficeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AgentTimelineProvider()) { entry in
            AgentWidgetView(data: entry.data)
                .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName("Agent Office")
        .description("AI 에이전트 파이프라인 상태를 실시간으로 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
