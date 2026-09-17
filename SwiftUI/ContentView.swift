import SwiftUI

#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: ActionPhase = .qr

    private var animation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.12)
            : .spring(response: 0.52, dampingFraction: 0.88)
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ContextualActionSplit(
                phase: $phase,
                animation: animation
            ) { action in
                handle(action)
            }
            .padding(10)
        }
    }

    private var backgroundColor: Color {
        #if os(iOS)
        Color(uiColor: .systemGroupedBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.clear
        #endif
    }

    private func handle(_ action: ActionItem) {
        withAnimation(animation) {
            switch action.id {
            case "scan":
                phase = .qr
            case "my-qr":
                phase = .payment
            case "contact":
                phase = phase == .discover ? .qr : .discover
            case "pay", "request":
                phase = .discover
            case "close":
                phase = .discover
            default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
