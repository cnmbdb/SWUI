import SwiftUI

enum ActionPhase: String, CaseIterable, Identifiable {
    case discover
    case qr
    case payment

    var id: Self { self }

    var title: String {
        switch self {
        case .discover:
            return "Discover"
        case .qr:
            return "My QR"
        case .payment:
            return "Payment"
        }
    }

    var actions: [ActionItem] {
        switch self {
        case .discover:
            return [
                ActionItem(id: "contact", title: "Contact", systemImage: "person.crop.circle", style: .neutral),
                ActionItem(id: "scan", title: "Scan QR", systemImage: "qrcode", style: .neutral),
                ActionItem(id: "close", title: "Close", systemImage: "xmark", style: .close)
            ]
        case .qr:
            return [
                ActionItem(id: "close", title: "Close", systemImage: "xmark", style: .close),
                ActionItem(id: "contact", title: "Contact", systemImage: "person.crop.circle", style: .neutral),
                ActionItem(id: "my-qr", title: "My QR", systemImage: "qrcode", style: .neutral)
            ]
        case .payment:
            return [
                ActionItem(id: "pay", title: "Pay", systemImage: "arrow.up.right", style: .pay),
                ActionItem(id: "request", title: "Request", systemImage: "arrow.down.left", style: .request)
            ]
        }
    }

    var next: ActionPhase {
        switch self {
        case .discover:
            return .qr
        case .qr:
            return .payment
        case .payment:
            return .discover
        }
    }
}

struct ActionItem: Identifiable {
    enum Style {
        case neutral
        case close
        case pay
        case request
    }

    let id: String
    let title: String
    let systemImage: String
    let style: Style
}

struct ContextualActionSplit: View {
    @Binding var phase: ActionPhase
    let animation: Animation
    let onSelect: (ActionItem) -> Void

    @Namespace private var namespace

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    }

                ambientLight
                actionRail
            }
            .frame(maxWidth: .infinity)
            .frame(height: 296)
            .clipped()

            HStack {
                Text(phase.title)
                    .font(.system(.caption, design: .rounded).weight(.semibold))

                Spacer()

                HStack(spacing: 8) {
                    ForEach(ActionPhase.allCases) { currentPhase in
                        Button {
                            withAnimation(animation) {
                                phase = currentPhase
                            }
                        } label: {
                            Circle()
                                .fill(currentPhase == phase ? Color.primary : Color.primary.opacity(0.18))
                                .frame(width: 7, height: 7)
                                .scaleEffect(currentPhase == phase ? 1.4 : 1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(currentPhase.title) context")
                    }
                }
            }
            .padding(.top, 12)
        }
    }

    private var ambientLight: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.08, green: 0.80, blue: 0.42).opacity(0.13))
                .frame(width: 176, height: 176)
                .blur(radius: 34)
                .offset(x: -118, y: -72)

            Circle()
                .fill(Color(red: 0.21, green: 0.58, blue: 0.94).opacity(0.12))
                .frame(width: 156, height: 156)
                .blur(radius: 32)
                .offset(x: 120, y: 74)
        }
        .allowsHitTesting(false)
    }

    private var actionRail: some View {
        GlassEffectContainer(spacing: 18) {
            actionItems
        }
    }

    private var actionItems: some View {
        HStack(spacing: 12) {
            ForEach(phase.actions) { action in
                actionView(for: action)
                .matchedGeometryEffect(id: "pill-\(action.id)", in: namespace)
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.82).combined(with: .opacity),
                        removal: .scale(scale: 1.08).combined(with: .opacity)
                    )
                )
            }
        }
        .padding(20)
        .animation(animation, value: phase)
    }

    private func actionView(for action: ActionItem) -> some View {
        ActionPill(action: action) {
            onSelect(action)
        }
        .glassEffectID(action.id, in: namespace)
        .glassEffectTransition(.matchedGeometry)
    }
}

private struct ActionPill: View {
    let action: ActionItem
    let onSelect: () -> Void

    private var labelFont: Font {
        .system(.body, design: .rounded).weight(.semibold)
    }

    var body: some View {
        Button(action: onSelect) {
            content
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
        .accessibilityLabel(action.title)
        .accessibilityHint("Changes the current action context")
    }

    @ViewBuilder
    private var content: some View {
        switch action.style {
        case .neutral:
            HStack(spacing: 10) {
                Image(systemName: action.systemImage)
                    .font(.system(size: 20, weight: .semibold))

                Text(action.title)
                    .font(labelFont)
                    .lineLimit(1)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 18)
            .frame(minHeight: 54)
            .glassEffect(.regular.interactive(), in: Capsule())

        case .close:
            Image(systemName: action.systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 54, height: 54)
                .glassEffect(.regular.interactive(), in: Circle())

        case .pay, .request:
            let accent: Color
            switch action.style {
            case .pay:
                accent = Color(red: 0.08, green: 0.80, blue: 0.42)
            case .request:
                accent = Color(red: 0.21, green: 0.58, blue: 0.94)
            default:
                accent = .clear
            }

            HStack(spacing: 10) {
                Image(systemName: action.systemImage)
                    .font(.system(size: 19, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(accent, in: Circle())

                Text(action.title)
                    .font(labelFont)
                    .lineLimit(1)
            }
            .foregroundStyle(.primary)
            .padding(.leading, 5)
            .padding(.trailing, 18)
            .frame(minHeight: 54)
            .glassEffect(.regular.tint(accent).interactive(), in: Capsule())
        }
    }
}
