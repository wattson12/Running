import Resources
import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 150)

            Image(systemName: "figure.run")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)

            Text(L10n.Runs.Empty.title)
                .font(.largeTitle)
                .foregroundColor(.primary)

            Text(L10n.Runs.Empty.message)
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundColor(.primary)

            Spacer()

            Text(.init(verbatim: L10n.Runs.Empty.caption))
                .tint(.primary)
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    EmptyView()
}
