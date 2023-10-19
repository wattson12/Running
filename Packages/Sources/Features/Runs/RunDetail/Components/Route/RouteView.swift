import Model
import SwiftUI

struct RouteView: View {
    let locations: [Location]

    var body: some View {
        MapView(locations: locations)
    }
}

#Preview {
    RouteView(locations: .loop)
}
