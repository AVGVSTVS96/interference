import CoreMotion
import SwiftUI
import WebKit

@main
struct InterferenceApp: App {
    @Environment(\.scenePhase) private var phase

    var body: some Scene {
        WindowGroup {
            Page()
                .ignoresSafeArea()
                .onChange(of: phase, initial: true) { _, phase in
                    UIApplication.shared.isIdleTimerDisabled = phase == .active
                    if phase == .active { tellHangar() }
                }
        }
    }
}

/// interference.bassim.run, fed this phone's magnetometer: `magnet(x, y, z, turn)` sixty times a second, the field in
/// µT on the phone's own axes and how fast the phone is turning, in radians a second.
struct Page: UIViewRepresentable {
    static let address = URL(string: "https://interference.bassim.run/")!

    func makeCoordinator() -> Feed { Feed() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.addUserScript(
            WKUserScript(source: "window.magnetApp = true", injectionTime: .atDocumentStart, forMainFrameOnly: true))
        config.userContentController.add(Haptic(), name: "haptic")
        let view = WKWebView(frame: .zero, configuration: config)
        view.isOpaque = false
        view.backgroundColor = .systemBackground
        view.scrollView.contentInsetAdjustmentBehavior = .never
        view.allowsLinkPreview = false
        view.load(URLRequest(url: Self.address, cachePolicy: .reloadRevalidatingCacheData))
        context.coordinator.start(feeding: view)
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {}
}

final class Feed {
    private let motion = CMMotionManager()

    func start(feeding view: WKWebView) {
        motion.magnetometerUpdateInterval = 1 / 60
        motion.deviceMotionUpdateInterval = 1 / 60
        motion.startDeviceMotionUpdates()
        motion.startMagnetometerUpdates(to: .main) { [weak self, weak view] data, _ in
            guard let field = data?.magneticField, let view else { return }
            let r = self?.motion.deviceMotion?.rotationRate
            let turn = r.map { ($0.x * $0.x + $0.y * $0.y + $0.z * $0.z).squareRoot() } ?? 0
            view.evaluateJavaScript(
                String(format: "window.magnet && magnet(%.2f, %.2f, %.2f, %.3f)", field.x, field.y, field.z, turn))
        }
    }
}

/// A tap felt when the page has caught the other phone at an edge.
final class Haptic: NSObject, WKScriptMessageHandler {
    private let feedback = UIImpactFeedbackGenerator(style: .rigid)

    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        feedback.impactOccurred()
    }
}

/// Tells hangar which build runs here, so it shows as up to date.
private func tellHangar() {
    guard let base = Bundle.main.object(forInfoDictionaryKey: "HangarURL") as? String,
        let url = URL(string: base + "/running"),
        let build = Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "")
    else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "content-type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: ["id": Bundle.main.bundleIdentifier ?? "", "build": build])
    URLSession.shared.dataTask(with: request).resume()
}
