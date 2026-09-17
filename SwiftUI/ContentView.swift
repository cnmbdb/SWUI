import SwiftUI

struct ContentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: ActionPhase = .discover
    @State private var isPlaying = true

    private var animation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.12)
            : .spring(response: 0.52, dampingFraction: 0.88)
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    header
                    intro
                    demo
                    motionNote
                    sourceNote
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 20)
            }
            .scrollIndicators(.hidden)
        }
        .task(id: isPlaying) {
            guard isPlaying, !reduceMotion else { return }

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_800_000_000)
                guard !Task.isCancelled else { return }

                withAnimation(animation) {
                    phase = phase.next
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("SWUI")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .tracking(1.6)

            Spacer()

            Text("Native interaction study")
                .font(.system(.caption, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Context changes the action.")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .tracking(-1.2)
                .fixedSize(horizontal: false, vertical: true)

            Text("A small SwiftUI prototype for actions that split, merge, and move with the moment.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var demo: some View {
        VStack(alignment: .leading, spacing: 14) {
            ContextualActionSplit(
                phase: $phase,
                isPlaying: $isPlaying,
                animation: animation
            ) { action in
                handle(action)
            }

            Picker("Context", selection: $phase) {
                ForEach(ActionPhase.allCases) { currentPhase in
                    Text(currentPhase.title)
                        .tag(currentPhase)
                }
            }
            .pickerStyle(.segmented)
            .animation(animation, value: phase)

            HStack(spacing: 10) {
                Button {
                    isPlaying.toggle()
                } label: {
                    Label(
                        isPlaying ? "Pause sequence" : "Play sequence",
                        systemImage: isPlaying ? "pause.fill" : "play.fill"
                    )
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                }
                .buttonStyle(.glass)

                Text("Tap any state to inspect the split.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var motionNote: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The motion rule")
                .font(.system(.title3, design: .rounded).weight(.bold))

            Text("SwiftUI keeps the interaction interruptible. The spring starts from the current presentation value, so a new context can take over without a hard reset.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)

            Text("withAnimation(.spring(response: 0.52, dampingFraction: 0.88))")
                .font(.system(.footnote, design: .monospaced).weight(.medium))
                .foregroundStyle(.white)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var sourceNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Open SWUI.xcodeproj to run the native version.", systemImage: "arrow.up.right.square")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))

            Text("This build targets iOS 27 and uses the refreshed native Liquid Glass appearance. The web showcase in docs/ mirrors the same three-state model for GitHub Pages.")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 18)
    }

    private func handle(_ action: ActionItem) {
        withAnimation(animation) {
            switch action.id {
            case "scan":
                phase = .qr
                isPlaying = false
            case "pay", "request":
                phase = .payment
                isPlaying = false
            case "close":
                phase = .discover
                isPlaying = false
            default:
                isPlaying = false
            }
        }
    }
}

#Preview {
    ContentView()
}
