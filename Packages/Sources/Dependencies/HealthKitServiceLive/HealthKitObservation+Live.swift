import DependenciesAdditions
import Foundation
import HealthKit
import HealthKitServiceInterface
import Model

extension UserDefaults.Dependency {
    func addMessage(_ message: String) {
        var logging: ObservationLogging
        if let data = data(forKey: "observation_logging") {
            if let existingValue = try? JSONDecoder().decode(ObservationLogging.self, from: data) {
                logging = existingValue
            } else {
                logging = .init(messages: [])
            }
        } else {
            logging = .init(messages: [])
        }

        logging.messages.append(.init(date: Date(), message: message))

        if let updatedData = try? JSONEncoder().encode(logging) {
            set(updatedData, forKey: "observation_logging")
        }
    }
}

extension HealthKitObservation {
    static func live() -> Self {
        @Dependency(\.userDefaults) var userDefaults

        return .init(
            enableBackgroundDelivery: {
                try await HKHealthStore.shared.enableBackgroundDelivery(for: .workoutType(), frequency: .immediate)
                userDefaults.addMessage("Enabled background delivery")
            },
            observeWorkouts: {
                // add message that observer query was created
                userDefaults.addMessage("HKObserverQuery created for .workoutType()")

                let predicate = HKQuery.predicateForWorkouts(with: .running)
                let query = HKObserverQuery(
                    sampleType: .workoutType(),
                    predicate: predicate,
                    updateHandler: { _, completionHandler, error in
                        // add message that update was called
                        userDefaults.addMessage("HKObserverQuery callback fired for .workoutType(). Error: \(error as Any)")
                        completionHandler()
                    }
                )
                HKHealthStore.shared.execute(query)
            }
        )
    }
}
