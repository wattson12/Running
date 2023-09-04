import SwiftUI

public struct WidgetView<Content: View>: View {
    let content: () -> Content

    @Environment(\.tintColor) var tint

    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }

    public var body: some View {
        HStack(alignment: .top) {
            content()
        }
        .frame(maxWidth: .infinity)
        .padding() // internal padding
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(tint, lineWidth: 2)
        )
        .padding(.horizontal, 16) // external padding
    }
}

#Preview {
    WidgetView {
        Text("Content")
    }
}
