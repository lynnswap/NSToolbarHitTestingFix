# NSToolbarHitTestingFix

A lightweight Swift package that installs a hit-testing workaround for toolbar regions on macOS 26 beta. Buttons positioned behind `NSToolbarView` become clickable once the modifier is applied.

## Usage

Apply the `toolbarClickThrough()` modifier to any SwiftUI view that should forward interactions through the toolbar. On macOS versions earlier than 26, calling the modifier has no effect.

```swift
Text("Hello")
    .toolbarClickThrough()
```

The implementation registers a swizzled `hitTest` on `NSGlassContainerView` the first time a window installs the modifier. A singleton registry keeps track of installed windows. The package is intended only for experimental use during the macOS 26 beta.

## Feedback

- Feedback Assistant: FB18201935
- Apple Developer Forum: [SwiftUI buttons behind NSToolbarView are not clickable on macOS 26 beta](https://developer.apple.com/forums/thread/788928)

## License

Released under the MIT license. See [LICENSE](LICENSE) for details.

