import DesignSystem
import Model
import Repository
import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    @Environment(\.tintColor) var tint

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    tint.opacity(0.5),
                    lineWidth: 6
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    tint,
                    style: StrokeStyle(
                        lineWidth: 6,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}

struct ProgressViewWithPercentage: View {
    let progress: CGFloat
    @Environment(\.tintColor) var tint

    var body: some View {
        ZStack {
            CircularProgressView(
                progress: progress
            )
            .frame(width: 80, height: 80)

            Text(percentage)
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }

    var percentage: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.roundingMode = .floor
        numberFormatter.maximumFractionDigits = 1
        if let formatted = numberFormatter.string(from: .init(value: progress)) {
            return formatted
        } else {
            return String(format: "%.2f%%", progress)
        }
    }
}

struct GoalRowView: View {
    enum GoalState {
        case noGoal
        case goalSet(distance: Measurement<UnitLength>, target: Measurement<UnitLength>)
    }

    let state: GoalState
    let title: String
    let action: () -> Void
    let editAction: () -> Void

    @Environment(\.locale) var locale

    init(
        goal: Goal,
        distance: Measurement<UnitLength>,
        action: @escaping () -> Void,
        editAction: @escaping () -> Void
    ) {
        if let target = goal.target {
            state = .goalSet(
                distance: distance.converted(to: .primaryUnit()),
                target: target.converted(to: .primaryUnit())
            )
        } else {
            state = .noGoal
        }
        switch goal.period {
        case .weekly:
            title = "Weekly"
        case .monthly:
            title = "Monthly"
        case .yearly:
            title = "Yearly"
        }

        self.action = action
        self.editAction = editAction
    }

    var body: some View {
        Button(
            action: action,
            label: {
                WidgetView {
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.title.bold())
                            .foregroundColor(.primary)

                        ForEach(Array(subtitles.enumerated()), id: \.offset) { _, subtitle in
                            Text(subtitle)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button(
                            action: editAction,
                            label: {
                                Image(systemName: "gear")
                            }
                        )
                        .buttonStyle(.plain)
                        .tint(.secondary)
                    }

                    Spacer()

                    ProgressViewWithPercentage(
                        progress: progress
                    )
                    .blur(radius: blur)
                    .padding(8)
                }
            }
        )
    }

    var subtitles: [String] {
        switch state {
        case .noGoal:
            return [
                "No goal set",
            ]
        case let .goalSet(distance, target) where distance < target:
            let remaining = target - distance
            return [
                formattedDistance(distance: distance),
                formattedRemaining(remaining: remaining),
            ]
        case let .goalSet(distance, _):
            return [
                formattedDistance(distance: distance),
            ]
        }
    }

    var blur: CGFloat {
        guard case .noGoal = state else { return 0 }
        return 5
    }

    var progress: CGFloat {
        guard case let .goalSet(distance, goal) = state else { return 0 }
        return distance.value / goal.value
    }

    func formattedRemaining(remaining: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.locale = locale
        formatter.unitStyle = .medium

        let numberformatter = NumberFormatter()
        numberformatter.locale = locale
        numberformatter.maximumFractionDigits = 2
        formatter.numberFormatter = numberformatter

        let formattedRemaining = formatter.string(from: remaining.converted(to: .primaryUnit(locale: locale)))
        return "\(formattedRemaining) remaining"
    }

    func formattedDistance(distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.locale = locale
        formatter.unitStyle = .medium

        let numberformatter = NumberFormatter()
        numberformatter.locale = locale
        numberformatter.maximumFractionDigits = 2
        formatter.numberFormatter = numberformatter

        return formatter.string(from: distance.converted(to: .primaryUnit(locale: locale)))
    }
}

struct GoalRow_Previews: PreviewProvider {
    static var previews: some View {
        GoalRowView(
            goal: .init(
                period: .weekly,
                target: .init(value: 1000, unit: .kilometers)
            ),
            distance: .init(value: 750, unit: .kilometers),
            action: { print("tapped") },
            editAction: { print("tapped") }
        )
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewLayout(.fixed(width: 375, height: 200))
        .previewDisplayName("75%")

        GoalRowView(
            goal: .init(
                period: .weekly,
                target: .init(value: 1000, unit: .kilometers)
            ),
            distance: .init(value: 1100, unit: .kilometers),
            action: { print("tapped") },
            editAction: { print("tapped") }
        )
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewLayout(.fixed(width: 375, height: 200))
        .previewDisplayName("Goal Achieved")

        GoalRowView(
            goal: .init(period: .weekly, target: nil),
            distance: .init(value: 50, unit: .kilometers),
            action: { print("tapped") },
            editAction: { print("tapped") }
        )
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewLayout(.fixed(width: 375, height: 200))
        .previewDisplayName("No Goal")

        GoalRowView(
            goal: .init(
                period: .weekly,
                target: .init(value: 1000, unit: .miles)
            ),
            distance: .init(value: 750, unit: .miles),
            action: { print("tapped") },
            editAction: { print("tapped") }
        )
        .environment(\.locale, .init(identifier: "en_GB"))
        .previewLayout(.fixed(width: 375, height: 200))
        .previewDisplayName("75% (Imperial)")
    }
}
