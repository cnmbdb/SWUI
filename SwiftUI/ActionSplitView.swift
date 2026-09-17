import SwiftUI

enum ActionPhase {
    case discover
    case qr
    case payment

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

}

struct ActionItem: Identifiable {
    enum Style: Equatable {
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
        ZStack {
            ambientLight

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28, style: .continuous))

            actionRail
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.16, contentMode: .fit)
        .clipped()
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
        GlassEffectContainer(spacing: 12) {
            actionItems
        }
    }

    private var actionItems: some View {
        HStack(spacing: 12) {
            ForEach(phase.actions) { action in
                actionView(for: action)
            }
        }
        .padding(20)
        .animation(animation, value: phase)
    }

    private func actionView(for action: ActionItem) -> some View {
        actionButton(for: action)
        .glassEffectID(action.id, in: namespace)
        .glassEffectTransition(.matchedGeometry)
    }

    @ViewBuilder
    private func actionButton(for action: ActionItem) -> some View {
        switch action.style {
        case .neutral:
            Button {
                onSelect(action)
            } label: {
                Label(action.title, systemImage: action.systemImage)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .lineLimit(1)
            }
            .buttonStyle(.glass)
            .accessibilityLabel(action.title)
            .accessibilityHint("Changes the current action context")

        case .close:
            Button {
                onSelect(action)
            } label: {
                Image(systemName: action.systemImage)
                    .font(.system(size: 20, weight: .semibold))
            }
            .buttonStyle(.glass)
            .frame(width: 54, height: 54)
            .accessibilityLabel(action.title)
            .accessibilityHint("Changes the current action context")

        case .pay, .request:
            Button {
                onSelect(action)
            } label: {
                Label(action.title, systemImage: action.systemImage)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .lineLimit(1)
            }
            .buttonStyle(.glassProminent)
            .tint(action.style == .pay
                ? Color(red: 0.08, green: 0.80, blue: 0.42)
                : Color(red: 0.21, green: 0.58, blue: 0.94))
            .accessibilityLabel(action.title)
            .accessibilityHint("Changes the current action context")
        }
    }
}
