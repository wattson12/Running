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

                        Text(run.startDate, formatter: DateFormatter.run)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(run.duration.fullValue(locale: locale))
                            .font(.title2)

                        Text(run.formattedPace(locale: locale))
                            .font(.footnote)
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
                duration: 62.23
            ),
            tapped: { print("tapped") }
        )
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewDisplayName("Metric")
    }
}
