import SwiftUI
import AppKit

// Provides a workaround for toolbar hit testing issues on macOS 26 beta.
// Apply `toolbarClickThrough()` to a view to allow interactions with elements
// behind the toolbar.

extension View {
    @available(macOS 26.0, *)
    func toolbarClickThrough() -> some View {
        modifier(ToolbarClickThroughModifier())
    }
}

@available(macOS 26.0, *)
private struct ToolbarClickThroughModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ToolbarClickThroughInstaller()
                    .frame(width: 0, height: 0)
            )
    }
}

// MARK: - Installer (NSViewRepresentable)
@available(macOS 26.0, *)
private struct ToolbarClickThroughInstaller: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        Task { @MainActor in
            guard let window = view.window else { return }
            registerToolbarClickThrough(for: window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

// MARK: - Low-level Core
@available(macOS 26.0, *)

@available(macOS 26.0, *)
@MainActor
func installToolbarClickThroughSwizzle() {
    guard
        let glassClass = NSClassFromString("NSGlassContainerView"),
        let itemViewerClass = NSClassFromString("NSToolbarItemViewer"),
        let m = class_getInstanceMethod(glassClass, #selector(NSView.hitTest(_:)))
    else { return }

    typealias CFunc = @convention(c)(AnyObject, Selector, NSPoint) -> Unmanaged<NSView>?
    let original = unsafeBitCast(method_getImplementation(m), to: CFunc.self)

    let block: @convention(block)(AnyObject, NSPoint) -> NSView? = { obj, pt in
        guard let hit = original(obj, #selector(NSView.hitTest(_:)), pt)?.takeUnretainedValue()
        else { return nil }

        if ToolbarClickThroughRegistry.shared.contains(obj) {
            return isToolbarItemViewer(hit, itemViewerClass: itemViewerClass) ? hit : nil
        }
        return hit
    }
    method_setImplementation(m, imp_implementationWithBlock(block))
}

@available(macOS 26.0, *)
@MainActor
func registerToolbarClickThrough(for window: NSWindow) {
    ToolbarClickThroughRegistry.shared.ensureSwizzleInstalled {
        installToolbarClickThroughSwizzle()
    }
    ToolbarClickThroughRegistry.shared.addViews(from: window)
}

@MainActor
func firstGlassContainerView(in root: NSView) -> NSView? {
    guard let cls = NSClassFromString("NSGlassContainerView") else { return nil }
    return root.firstDescendant { $0.isKind(of: cls) }
}

@MainActor
func firstToolbarView(in window: NSWindow) -> NSView? {
    guard
        let frameView = window.contentView?.superview,
        let cls = NSClassFromString("NSToolbarView")
    else { return nil }
    return frameView.firstDescendant { $0.isKind(of: cls) }
}

@MainActor
private func isToolbarItemViewer(_ view: NSView, itemViewerClass: AnyClass) -> Bool {
    var v: NSView? = view
    while let current = v {
        if current.isKind(of: itemViewerClass) { return true }
        v = current.superview
    }
    return false
}

private extension NSView {
    func firstDescendant(where test: (NSView) -> Bool) -> NSView? {
        if test(self) { return self }
        for sub in subviews {
            if let hit = sub.firstDescendant(where: test) { return hit }
        }
        return nil
    }
}
