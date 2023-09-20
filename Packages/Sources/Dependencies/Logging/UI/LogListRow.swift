import SwiftUI

struct LogListRow: View {
    let log: ActionLog

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(
                    log.timestamp
                        .formatted(
                            .dateTime.year(.twoDigits)
                                .month(.twoDigits)
                                .day(.twoDigits)
                                .hour(.twoDigits(amPM: .abbreviated))
                                .minute(.twoDigits)
                                .second(.twoDigits)
                                .secondFraction(.fractional(2))
                        )
                )

                Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(log.actionLabel)
        }
    }
}

#Preview {
    LogListRow(log: .mock())
}
