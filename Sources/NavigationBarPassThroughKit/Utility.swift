import SwiftUI

#if canImport(AppKit)
@MainActor
func installNavigationBarPassThroughSwizzle() {
    guard let glassClass = NSClassFromString("NSGlassContainerView"),
          let itemViewerClass = NSClassFromString("NSToolbarItemViewer"),
          let m = class_getInstanceMethod(glassClass, #selector(NSView.hitTest(_:))) else {
        return
    }

    typealias CFunc = @convention(c)(AnyObject, Selector, NSPoint) -> Unmanaged<NSView>?
    let original = unsafeBitCast(method_getImplementation(m), to: CFunc.self)

    let block: @convention(block)(AnyObject, NSPoint) -> NSView? = { obj, pt in
        guard let hit = original(obj, #selector(NSView.hitTest(_:)), pt)?.takeUnretainedValue()
        else { return nil }

        if ClickThroughRegistry.shared.contains(obj) {
            return isToolbarItemViewer(hit, itemViewerClass: itemViewerClass) ? hit : nil
        }
        return hit
    }
    method_setImplementation(m, imp_implementationWithBlock(block))
}

@MainActor
func firstContainerView(in root: NSView) -> NSView? {
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
extension NSView {
    func firstDescendant(where test: (NSView) -> Bool) -> NSView? {
        if test(self) { return self }
        for sub in subviews {
            if let hit = sub.firstDescendant(where: test) { return hit }
        }
        return nil
    }

    func forEachDescendant(_ visit: (NSView) -> Void) {
        visit(self)
        for v in subviews { v.forEachDescendant(visit) }
    }
}
#elseif canImport(UIKit)

@MainActor
func installNavigationBarPassThroughSwizzle() {
    guard let glassClass = NSClassFromString("_UIBarContentView"),
          let itemViewerClass = NSClassFromString("_UINavigationBarPlatterView"),
          let m = class_getInstanceMethod(glassClass, #selector(UIView.hitTest(_:with:))) else {
        return
    }
    
    typealias CFunc = @convention(c)(AnyObject, Selector, CGPoint, UIEvent?) -> UIView?
    let original = unsafeBitCast(method_getImplementation(m), to: CFunc.self)

    let block: @convention(block)(AnyObject, CGPoint, UIEvent?) -> UIView? = { obj, pt, event in
        guard let hit = original(obj, #selector(UIView.hitTest(_:with:)), pt, event) else {
            return nil
        }

        if ClickThroughRegistry.shared.contains(obj) {
            return isToolbarItemViewer(hit, itemViewerClass: itemViewerClass) ? hit : nil
        }
        return hit
    }
    method_setImplementation(m, imp_implementationWithBlock(block))
}

@MainActor
func firstContainerView(in root: UIView) -> UIView? {
    guard let cls = NSClassFromString("_UIBarContentView") else { return nil }
    return root.firstDescendant { $0.isKind(of: cls) }
}
@MainActor
private func isToolbarItemViewer(_ view: UIView, itemViewerClass: AnyClass) -> Bool {
    var v: UIView? = view
    while let current = v {
        if current.isKind(of: itemViewerClass) { return true }
        v = current.superview
    }
    return false
}
extension UIView {
    func firstDescendant(where test: (UIView) -> Bool) -> UIView? {
        if test(self) { return self }
        for sub in subviews {
            if let hit = sub.firstDescendant(where: test) { return hit }
        }
        return nil
    }

    func forEachDescendant(_ visit: (UIView) -> Void) {
        visit(self)
        for v in subviews { v.forEachDescendant(visit) }
    }
}
#endif
