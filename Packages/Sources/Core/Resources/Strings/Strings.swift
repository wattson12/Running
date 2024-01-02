// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
    public enum App {
        public enum Feature {
            /// Debug
            public static let debug = L10n.tr("Localizable", "app.feature.debug", fallback: "Debug")
            /// Localizable.strings
            ///
            ///
            ///   Created by Sam Watts on 02/09/2023.
            public static let goals = L10n.tr("Localizable", "app.feature.goals", fallback: "Goals")
            /// History
            public static let history = L10n.tr("Localizable", "app.feature.history", fallback: "History")
            /// Runs
            public static let runs = L10n.tr("Localizable", "app.feature.runs", fallback: "Runs")
            /// About
            public static let settings = L10n.tr("Localizable", "app.feature.settings", fallback: "About")
        }
    }

    public enum Goal {
        public enum Period {
            public enum Monthly {
                /// Monthly
                public static let displayName = L10n.tr("Localizable", "goal.period.monthly.display_name", fallback: "Monthly")
            }

            public enum Weekly {
                /// Weekly
                public static let displayName = L10n.tr("Localizable", "goal.period.weekly.display_name", fallback: "Weekly")
            }

            public enum Yearly {
                /// Yearly
                public static let displayName = L10n.tr("Localizable", "goal.period.yearly.display_name", fallback: "Yearly")
            }
        }
    }

    public enum Goals {
        public enum Detail {
            public enum Chart {
                /// No runs recorded for this goal
                public static let noRunsOverlay = L10n.tr("Localizable", "goals.detail.chart.no_runs_overlay", fallback: "No runs recorded for this goal")
            }

            public enum Summary {
                /// Distance
                public static let distance = L10n.tr("Localizable", "goals.detail.summary.distance", fallback: "Distance")
                /// Goal
                public static let goal = L10n.tr("Localizable", "goals.detail.summary.goal", fallback: "Goal")
                /// Remaining
                public static let remaining = L10n.tr("Localizable", "goals.detail.summary.remaining", fallback: "Remaining")
            }
        }

        public enum Edit {
            /// Previous goal: %@
            public static func previousGoalFormat(_ p1: Any) -> String {
                L10n.tr("Localizable", "goals.edit.previous_goal_format", String(describing: p1), fallback: "Previous goal: %@")
            }

            /// Set goal
            public static let setGoal = L10n.tr("Localizable", "goals.edit.set_goal", fallback: "Set goal")
            /// Update goal
            public static let updateGoal = L10n.tr("Localizable", "goals.edit.update_goal", fallback: "Update goal")
            public enum Button {
                /// Clear goal
                public static let clear = L10n.tr("Localizable", "goals.edit.button.clear", fallback: "Clear goal")
            }
        }
    }

    public enum Permissions {
        public enum HealthKitUnavailable {
            /// We use running workouts to update your running goals. This device doesn't currently support importing workouts so we can't track your goals
            public static let message = L10n.tr("Localizable", "permissions.health_kit_unavailable.message", fallback: "We use running workouts to update your running goals. This device doesn't currently support importing workouts so we can't track your goals")
            /// Workouts not suppported
            public static let title = L10n.tr("Localizable", "permissions.health_kit_unavailable.title", fallback: "Workouts not suppported")
        }

        public enum RequestPermissions {
            /// Running Goals uses running workouts to update your running goals. Tap the button below and accept permissions to get started
            public static let messagePartOne = L10n.tr("Localizable", "permissions.request_permissions.message_part_one", fallback: "Running Goals uses running workouts to update your running goals. Tap the button below and accept permissions to get started")
            /// Workout data is only stored locally to calculate progress for your goals and is **never** sent anywhere else (you can check the [source code](https://github.com/wattson12/Running) if you want to be sure)
            public static let messagePartTwo = L10n.tr("Localizable", "permissions.request_permissions.message_part_two", fallback: "Workout data is only stored locally to calculate progress for your goals and is **never** sent anywhere else (you can check the [source code](https://github.com/wattson12/Running) if you want to be sure)")
            /// Permission required
            public static let title = L10n.tr("Localizable", "permissions.request_permissions.title", fallback: "Permission required")
            public enum Button {
                /// Get started
                public static let title = L10n.tr("Localizable", "permissions.request_permissions.button.title", fallback: "Get started")
            }
        }
    }

    public enum Runs {
        public enum Empty {
            /// Missing workouts?
            /// Check your permissions in the [Health](x-apple-health://) app
            public static let caption = L10n.tr("Localizable", "runs.empty.caption", fallback: "Missing workouts?\nCheck your permissions in the [Health](x-apple-health://) app")
            /// Track a running workout in the Health app (or an app linked to the Health app) and the run will be added here. Your goals will be updated automatically
            public static let message = L10n.tr("Localizable", "runs.empty.message", fallback: "Track a running workout in the Health app (or an app linked to the Health app) and the run will be added here. Your goals will be updated automatically")
            /// No runs (yet)
            public static let title = L10n.tr("Localizable", "runs.empty.title", fallback: "No runs (yet)")
        }

        public enum InitialImport {
            /// We're importing all of your running workouts tracked with the Health app. New workouts will be updated quickly, but it might take a little while the first time
            public static let message = L10n.tr("Localizable", "runs.initial_import.message", fallback: "We're importing all of your running workouts tracked with the Health app. New workouts will be updated quickly, but it might take a little while the first time")
            /// Importing runs
            public static let title = L10n.tr("Localizable", "runs.initial_import.title", fallback: "Importing runs")
        }

        public enum List {
            /// Today
            public static let today = L10n.tr("Localizable", "runs.list.today", fallback: "Today")
            /// Yesterday
            public static let yesterday = L10n.tr("Localizable", "runs.list.yesterday", fallback: "Yesterday")
        }
    }

    public enum Settings {
        public enum Section {
            /// Acknowledgements
            public static let acknowledgements = L10n.tr("Localizable", "settings.section.acknowledgements", fallback: "Acknowledgements")
            public enum BuildInfo {
                /// Build number
                public static let buildNumber = L10n.tr("Localizable", "settings.section.build_info.build_number", fallback: "Build number")
                /// Build info
                public static let title = L10n.tr("Localizable", "settings.section.build_info.title", fallback: "Build info")
                /// Version
                public static let version = L10n.tr("Localizable", "settings.section.build_info.version", fallback: "Version")
            }

            public enum Debug {
                /// Show debug tab
                public static let showDebugTab = L10n.tr("Localizable", "settings.section.debug.show_debug_tab", fallback: "Show debug tab")
                /// Show loggging
                public static let showLogging = L10n.tr("Localizable", "settings.section.debug.show_logging", fallback: "Show loggging")
                /// Debug
                public static let title = L10n.tr("Localizable", "settings.section.debug.title", fallback: "Debug")
            }

            public enum Links {
                /// Privacy policy
                public static let privacy = L10n.tr("Localizable", "settings.section.links.privacy", fallback: "Privacy policy")
                /// Source code
                public static let sourceCode = L10n.tr("Localizable", "settings.section.links.source_code", fallback: "Source code")
                /// Terms & conditions
                public static let terms = L10n.tr("Localizable", "settings.section.links.terms", fallback: "Terms & conditions")
                /// Links
                public static let title = L10n.tr("Localizable", "settings.section.links.title", fallback: "Links")
            }
        }
    }
}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
    private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
        let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

// swiftlint:disable convenience_type
private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: BundleToken.self)
        #endif
    }()
}

// swiftlint:enable convenience_type
