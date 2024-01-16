import DesignSystem
import Resources
import SwiftUI

struct IconBorderedView<Content: View>: View {
    let image: Image
    let title: String?
    let content: () -> Content

    @Environment(\.tintColor) var tintColor

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .clipShape(RoundedRectangle(cornerSize: .init(width: 6, height: 6)))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(tintColor, lineWidth: 2)
                        .padding(.top, 10)
                )

            HStack {
                Spacer().frame(width: 16)

                HStack(spacing: 4) {
                    image
                        .foregroundStyle(tintColor)

                    if let title {
                        Text(title)
                            .foregroundStyle(tintColor)
                            .font(.footnote)
                    }
                }
                .padding(.horizontal, 2)
                .background(Color.white)

                Spacer()
            }

            content()
                .cornerRadius(6)
                .padding(.top, 12)
                .padding(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/, 8)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    IconBorderedView(
        image: .init(systemName: "stopwatch"),
        title: "Splits",
        content: { Color.orange.frame(height: 200) }
    )
    .customTint(Color(asset: Asset.purple))
}
