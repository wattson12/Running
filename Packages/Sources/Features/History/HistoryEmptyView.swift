import Resources
import SwiftUI

struct HistoryEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 150)

            Image(systemName: "clock.arrow.circlepath")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)

            Text(L10n.History.Empty.title)
                .font(.largeTitle)
                .foregroundColor(.primary)

            Text(L10n.History.Empty.message)
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundColor(.primary)

            Spacer()

            Text(.init(L10n.History.Empty.caption))
                .tint(.primary)
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    HistoryEmptyView()
}
