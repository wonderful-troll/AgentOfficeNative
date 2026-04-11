import SwiftUI
import WidgetKit
import ServiceManagement

@main
struct AgentOfficeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            ContentView()
                .frame(width: 480, height: 560)
        }
    }
}

// ── AppDelegate — 백그라운드 파일 워처 ────────────────────────────────────────

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    private var fileWatchTimer: Timer?
    private var lastModDate: Date?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)   // 독 아이콘 숨기기

        // 메뉴바 아이콘
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "person.3.fill",
                                   accessibilityDescription: "Agent Office")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // 팝오버
        let pop = NSPopover()
        pop.contentSize = NSSize(width: 480, height: 560)
        pop.behavior = .transient
        pop.contentViewController = NSHostingController(rootView: ContentView())
        self.popover = pop

        // 파일 워처 + Darwin 알림 시작
        startWatcher()

        // 로그인 자동시작 등록 (SMAppService — App Store 규정 준수)
        try? SMAppService.mainApp.register()
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        if let popover, popover.isShown {
            popover.performClose(nil)
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    // ── 백그라운드 파일 워처 ─────────────────────────────────────────────────

    private func startWatcher() {
        lastModDate = SharedDataStore.statusFileModificationDate()

        // Darwin 알림 (update_widget.sh가 쓴 직후 즉시 신호)
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            { _, ptr, _, _, _ in
                guard let ptr else { return }
                Unmanaged<AppDelegate>.fromOpaque(ptr).takeUnretainedValue().syncWidget()
            },
            "com.agentoffice.update" as CFString,
            nil, .deliverImmediately
        )

        // 폴링 백업 (2초마다)
        fileWatchTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkFileChange()
        }
    }

    private func checkFileChange() {
        let mod = SharedDataStore.statusFileModificationDate()
        guard let mod, mod != lastModDate else { return }
        lastModDate = mod
        syncWidget()
    }

    /// JSON 파일 읽기 → UserDefaults 저장 → 위젯 타임라인 갱신
    @objc func syncWidget() {
        let data = SharedDataStore.load()
        SharedDataStore.save(data)   // UserDefaults 업데이트 + reloadAllTimelines()
    }
}
