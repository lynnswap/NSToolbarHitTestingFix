import AppKit

@available(macOS 26.0, *)
@MainActor
final class ToolbarClickThroughRegistry {
    static let shared = ToolbarClickThroughRegistry()

    private(set) var swizzleInstalled = false
    private let views = NSHashTable<AnyObject>.weakObjects()

    private init() {}

    func ensureSwizzleInstalled(_ installer: () -> Void) {
        guard !swizzleInstalled else { return }
        installer()
        swizzleInstalled = true
    }

    func addViews(from window: NSWindow) {
        guard let toolbarView = firstToolbarView(in: window),
              let glassView = firstGlassContainerView(in: toolbarView) else { return }
        views.add(toolbarView)
        views.add(glassView)
    }

    func contains(_ view: AnyObject) -> Bool {
        views.contains(view)
    }
}
