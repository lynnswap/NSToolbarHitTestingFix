
import SwiftUI

public extension View {
    // Public API aligned with NavigationBarPassThroughKit
    @ViewBuilder
    func navigationBarPassThrough() -> some View {
#if canImport(AppKit)
        if #available(macOS 26.0, *) {
            self.modifier(NavigationBarPassThroughModifier())
        } else {
            self
        }
#elseif canImport(UIKit)
        if #available(iOS 26.0, *) {
            self.modifier(NavigationBarPassThroughModifier())
        } else {
            self
        }
#else
        self
#endif
    }

}
struct NavigationBarPassThroughModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                NavigationBarPassThroughInstaller()
                    .frame(width: 0, height: 0)
            )
    }
}
