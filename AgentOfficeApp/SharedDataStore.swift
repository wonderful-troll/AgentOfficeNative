import Foundation
import WidgetKit

let appGroupID           = "group.com.agentoffice.app"
let widgetStatusFileName = "pipeline_status.json"

struct SharedDataStore {

    // ── App Group container ────────────────────────────────────────────────

    static var groupContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    static var statusFileURL: URL? {
        groupContainerURL?.appendingPathComponent(widgetStatusFileName)
    }

    // ── Load ───────────────────────────────────────────────────────────────

    static func load() -> PipelineData {
        guard let url = statusFileURL,
              let data = try? Data(contentsOf: url) else { return PipelineData() }

        // Try Unix timestamp format (written by Swift app)
        if let decoded = try? JSONDecoder().decode(PipelineData.self, from: data) {
            return decoded
        }
        // Try ISO8601 format (written by Python script)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode(PipelineData.self, from: data)) ?? PipelineData()
    }

    // ── Save ───────────────────────────────────────────────────────────────

    static func save(_ pipeline: PipelineData) {
        guard let url = statusFileURL,
              let encoded = try? JSONEncoder().encode(pipeline) else { return }
        try? encoded.write(to: url)
        WidgetCenter.shared.reloadAllTimelines()
    }

    // ── Modification date ──────────────────────────────────────────────────

    static func statusFileModificationDate() -> Date? {
        guard let url = statusFileURL else { return nil }
        return (try? FileManager.default.attributesOfItem(atPath: url.path))?[.modificationDate] as? Date
    }
}
