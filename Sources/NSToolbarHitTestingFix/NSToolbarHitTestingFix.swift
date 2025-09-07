
import SwiftUI

public extension View {
    @ViewBuilder
    func toolbarClickThrough() -> some View {
#if canImport(AppKit)
        if #available(macOS 26.0, *) {
            self.modifier(ToolbarClickThroughModifier())
        } else {
            self
        }
#elseif canImport(UIKit)
        if #available(iOS 26.0, *) {
            self.modifier(ToolbarClickThroughModifier())
        }else{
            self
        }
#else
        self
#endif
    }
}
struct ToolbarClickThroughModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ToolbarClickThroughInstaller()
                    .frame(width: 0, height: 0)
            )
    }
}
