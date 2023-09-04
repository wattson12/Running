import Model
import SwiftUI

struct RunListItemView: View {
    let run: Run

    @Environment(\.locale) var locale

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(run.distance.fullValue(locale: locale))
                    .font(.title)
                Text(run.formattedPace(locale: locale))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(run.duration.fullValue(locale: locale))
                    .font(.title2)

                Text(run.startDate, formatter: DateFormatter.run)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct RunListItemView_Previews: PreviewProvider {
    static var previews: some View {
        RunListItemView(
            run: .mock(
                date: "230312",
                distance: 10,
                duration: 52.23
            )
        )
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewDisplayName("Metric")
    }
}
