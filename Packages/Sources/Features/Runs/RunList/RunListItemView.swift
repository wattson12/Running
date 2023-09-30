import Model
import SwiftUI

struct RunListItemView: View {
    let run: Run
    let tapped: () -> Void

    @Environment(\.locale) var locale

    var body: some View {
        Button(
            action: tapped,
            label: {
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
                .contentShape(Rectangle())
            }
        )
        .buttonStyle(.plain)
    }
}

struct RunListItemView_Previews: PreviewProvider {
    static var previews: some View {
        RunListItemView(
            run: .mock(
                offset: 0,
                distance: 10,
                duration: 52.23
            ),
            tapped: { print("tapped") }
        )
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewDisplayName("Metric")
    }
}
