
import SwiftUI
#if canImport(AppKit)
struct ToolbarClickThroughInstaller: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        Task { @MainActor in
            guard let window = view.window else { return }
            ClickThroughRegistry.shared.ensureSwizzleInstalled {
                installToolbarClickThroughSwizzle()
            }
            if let toolbarView = firstToolbarView(in: window),
               let glassView = firstContainerView(in: toolbarView) {
                ClickThroughRegistry.shared.addObjects([toolbarView, glassView])
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
#elseif canImport(UIKit)
struct ToolbarClickThroughInstaller: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        Task { @MainActor in
            guard let window = view.window else { return }
            ClickThroughRegistry.shared.ensureSwizzleInstalled {
                installToolbarClickThroughSwizzle()
            }
            if let containerView = firstContainerView(in: window){
                ClickThroughRegistry.shared.addObjects([containerView])
            }
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
#endif
