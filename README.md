# SWUI

一个原生 SwiftUI 交互原型，复刻 withAnimationUI 的 contextual action split 概念。

项目把同一个状态机落在两个表面：

- SwiftUI/ 是真正的 iOS SwiftUI 实现，使用 SF Symbols、matchedGeometryEffect 和原生 spring。
- docs/ 是 GitHub Pages 展示页，提供可在线体验的同状态交互。Pages 不能直接运行 SwiftUI 二进制，因此在线页只负责展示和演示，不替代原生源码。

## 原生实现

打开 SWUI.xcodeproj，在 iOS 27 或更高版本运行。演示包含三个上下文：

- Discover：Contact、Scan QR、关闭
- My QR：关闭、Contact、My QR
- Payment：Pay、Request

核心动效使用 .spring(response: 0.52, dampingFraction: 0.88)，并在开启 Reduce Motion 时降级为短淡入淡出。

材质实现：项目锁定 iOS 27，使用最新 SwiftUI Liquid Glass，通过 GlassEffectContainer、.glassEffect(.regular.interactive(), in:)、glassEffectID 和 glassEffectTransition(.matchedGeometry) 让按钮产生系统级玻璃、交互高光与形状融合。Pay / Request 使用原生 Glass tint 表达语义颜色；暂停按钮使用系统 .glass button style。Pages 展示页同步使用半透明层、backdrop-filter、饱和度和内侧高光来复刻相同的玻璃层次，并响应 reduced transparency。

## 在线展示

GitHub Pages 入口：

https://cnmbdb.github.io/SWUI/

参考来源：

https://x.com/withAnimationUI/status/2099386664506581042

这是一个独立复刻练习。在线页没有上传或复用原推文视频，演示内容由本项目重新实现。

Apple Liquid Glass 参考：

https://developer.apple.com/documentation/swiftui/glasseffectcontainer

https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views
