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
    @Binding var isPlaying: Bool
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

                actionRail
            }
            .frame(maxWidth: .infinity)
            .frame(height: 296)
            .clipped()

            HStack {
                Text("Contextual action split")
                    .font(.system(.caption, design: .rounded).weight(.semibold))

                Spacer()

                Text(phase.title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 12)
        }
    }

    private var actionRail: some View {
        HStack(spacing: 12) {
            ForEach(phase.actions) { action in
                ActionPill(action: action) {
                    onSelect(action)
                }
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
            .foregroundStyle(.black)
            .padding(.horizontal, 18)
            .frame(minHeight: 54)
            .background(Color.white, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            }

        case .close:
            Image(systemName: action.systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 54, height: 54)
                .background(Color.white, in: Circle())
                .overlay {
                    Circle()
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                }

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
            .foregroundStyle(.black)
            .padding(.leading, 5)
            .padding(.trailing, 18)
            .frame(minHeight: 54)
            .background(Color.white, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            }
        }
    }
}
