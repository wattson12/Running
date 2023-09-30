import Resources
import SwiftUI

struct InitialImportView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 150)

            Image(systemName: "figure.run")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)

            Text(L10n.Runs.InitialImport.title)
                .font(.largeTitle)
                .foregroundColor(.primary)

            Text(L10n.Runs.InitialImport.message)
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    InitialImportView()
}
