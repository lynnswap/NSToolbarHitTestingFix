# NavigationBarPassThroughKit

A lightweight Swift package that lets navigation/toolbar backgrounds pass taps/clicks to views behind. Supports macOS and iOS. On supported OS versions it installs a targeted hit-testing override so views under the bar become interactive.

## Usage

Apply the `toolbarClickThrough()` modifier to any SwiftUI view that should forward interactions through the navigation/toolbar area. On older OS versions where the issue isn’t present, calling the modifier has no effect.

```swift
Text("Hello")
    .toolbarClickThrough()
```

Implementation details:
- macOS: Swizzles `NSGlassContainerView` under `NSToolbarView` so only real toolbar items hit-test; background passes through.
- iOS: Swizzles `_UIBarContentView` under `UINavigationBar` to allow taps to pass through the bar’s background while preserving hits on actual items.

Intended primarily for use during beta periods where hit-testing behavior changes; evaluate carefully for production use.

## Feedback

- Feedback Assistant: FB18201935
- Apple Developer Forum: [SwiftUI buttons behind NSToolbarView are not clickable on macOS 26 beta](https://developer.apple.com/forums/thread/788928)

## License

Released under the MIT license. See [LICENSE](LICENSE) for details.
