import AppIntents
import WidgetKit

// Interactive button in widget — triggers pipeline run
struct RunPipelineIntent: AppIntent {
    static var title: LocalizedStringResource = "파이프라인 실행"
    static var description = IntentDescription("에이전트 파이프라인을 시작합니다")

    func perform() async throws -> some IntentResult {
        // Mark pipeline as running and save to shared store
        var data = SharedDataStore.load()
        data.isRunning = true
        data.orchState = .working
        data.orchMessage = "파이프라인 시작 중..."
        data.logMessage = "▶ 실행 요청됨"
        data.results = []
        // Reset all agents
        for id in AgentID.allCases {
            data.agentStatuses[id.rawValue] = AgentStatus(state: .idle, message: "", progress: 0)
        }
        data.lastUpdated = Date()
        SharedDataStore.save(data)
        return .result()
    }
}

struct StopPipelineIntent: AppIntent {
    static var title: LocalizedStringResource = "파이프라인 중지"

    func perform() async throws -> some IntentResult {
        var data = SharedDataStore.load()
        data.isRunning = false
        data.orchState = .idle
        data.orchMessage = "대기 중"
        data.logMessage = "■ 중지됨"
        data.lastUpdated = Date()
        SharedDataStore.save(data)
        return .result()
    }
}
