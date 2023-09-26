import Resources
import SwiftUI

struct RequestPermissionsView: View {
    let requestPermissionsTapped: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 150)

            Image(systemName: "lock.open")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)

            Text(L10n.Permissions.RequestPermissions.title)
                .font(.largeTitle)
                .foregroundColor(.primary)

            Text(.init(L10n.Permissions.RequestPermissions.messagePartOne))
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundColor(.primary)

            Text(.init(L10n.Permissions.RequestPermissions.messagePartTwo))
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundColor(.primary)

            Spacer()

            Button(
                action: requestPermissionsTapped,
                label: {
                    Text(L10n.Permissions.RequestPermissions.Button.title)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
            )
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    RequestPermissionsView(requestPermissionsTapped: {})
}
