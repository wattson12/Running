import SwiftUI

struct ChartButton: View {
    let title: String
    let symbol: String
    @Binding var selected: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
            Text(title)
        }
        .font(.caption2)
        .foregroundColor(foregroundColor)
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
                .fill(fillColor)
        )
        .onTapGesture { selected.toggle() }
    }

    var foregroundColor: Color {
        if selected {
            Color.primary
        } else {
            Color.secondary
        }
    }

    var borderColor: Color {
        if selected {
            Color.accentColor
        } else {
            Color.secondary
        }
    }

    var fillColor: Color {
        if selected {
            Color.accentColor.opacity(0.25)
        } else {
            Color.clear
        }
    }
}

private struct ChartButtonPreviewWrapper: View {
    let title: String
    let symbol: String
    @State var selected: Bool

    var body: some View {
        ChartButton(
            title: title,
            symbol: symbol,
            selected: $selected
        )
    }
}

#Preview {
    ChartButtonPreviewWrapper(
        title: "Show Target",
        symbol: "target",
        selected: false
    )
}
