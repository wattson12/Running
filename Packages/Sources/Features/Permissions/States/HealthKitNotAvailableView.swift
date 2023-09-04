import Resources
import SwiftUI

struct HealthKitNotAvailableView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 150)

            Image(systemName: "iphone.gen3.slash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)

            Text(L10n.Permissions.HealthKitUnavailable.title)
                .font(.largeTitle)
                .foregroundColor(.primary)

            Text(L10n.Permissions.HealthKitUnavailable.message)
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    HealthKitNotAvailableView()
}
