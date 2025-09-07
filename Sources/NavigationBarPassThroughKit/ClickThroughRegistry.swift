import Foundation

@MainActor
final class ClickThroughRegistry {
    static let shared = ClickThroughRegistry()
    private init() {}

    private(set) var swizzleInstalled = false
    private let objects = NSHashTable<AnyObject>.weakObjects()

    func ensureSwizzleInstalled(_ installer: () -> Void) {
        guard !swizzleInstalled else { return }
        installer()
        swizzleInstalled = true
    }

    func addObjects(_ obs: [AnyObject]) {
        for o in obs { objects.add(o) }
    }

    func contains(_ obj: AnyObject) -> Bool { objects.contains(obj) }
}

