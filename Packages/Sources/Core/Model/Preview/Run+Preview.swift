import Dependencies
import Foundation

public extension [Run] {
    static let week: [Run] = {
        @Dependency(\.date) var date
        @Dependency(\.calendar) var calendar

        let startOfInterval = calendar.date(byAdding: .weekOfYear, value: -1, to: date.now)!
        return Array([Run].allRuns.prefix(while: { $0.startDate > startOfInterval }))
    }()

    static let month: [Run] = {
        @Dependency(\.date) var date
        @Dependency(\.calendar) var calendar

        let startOfInterval = calendar.date(byAdding: .month, value: -1, to: date.now)!
        return Array([Run].allRuns.prefix(while: { $0.startDate > startOfInterval }))
    }()

    static let year: [Run] = {
        @Dependency(\.date) var date
        @Dependency(\.calendar) var calendar

        let startOfInterval = calendar.date(byAdding: .year, value: -1, to: date.now)!
        return Array([Run].allRuns.prefix(while: { $0.startDate > startOfInterval }))
    }()

    static let allRuns: [Run] = {
        @Dependency(\.date) var date
        return [
            .mock(offset: 0, distance: 13.4, duration: 106.2),
            .mock(offset: -1, distance: 16.6, duration: 100.4),
            .mock(offset: -2, distance: 19.2, duration: 111.7),
            .mock(offset: -4, distance: 13.6, duration: 100.8),
            .mock(offset: -5, distance: 22.4, duration: 128.4),
            .mock(offset: -6, distance: 6.6, duration: 41.9),
            .mock(offset: -9, distance: 10.3, duration: 72.2),
            .mock(offset: -12, distance: 9.1, duration: 49.5),
            .mock(offset: -14, distance: 18.8, duration: 148.6),
            .mock(offset: -16, distance: 18.8, duration: 115.7),
            .mock(offset: -18, distance: 11.5, duration: 70.8),
            .mock(offset: -21, distance: 24.0, duration: 156.7),
            .mock(offset: -24, distance: 10.6, duration: 53.3),
            .mock(offset: -25, distance: 9.1, duration: 46.2),
            .mock(offset: -30, distance: 19.5, duration: 110.5),
            .mock(offset: -32, distance: 16.9, duration: 120.8),
            .mock(offset: -33, distance: 19.5, duration: 106.7),
            .mock(offset: -35, distance: 19.1, duration: 122.6),
            .mock(offset: -36, distance: 10.2, duration: 63.5),
            .mock(offset: -38, distance: 13.5, duration: 104.9),
            .mock(offset: -41, distance: 9.4, duration: 56.8),
            .mock(offset: -45, distance: 20.9, duration: 112.4),
            .mock(offset: -47, distance: 24.3, duration: 190.9),
            .mock(offset: -49, distance: 12.2, duration: 69.3),
            .mock(offset: -52, distance: 17.9, duration: 92.7),
            .mock(offset: -53, distance: 6.9, duration: 50.9),
            .mock(offset: -56, distance: 21.1, duration: 123.5),
            .mock(offset: -58, distance: 13.7, duration: 90.3),
            .mock(offset: -60, distance: 23.9, duration: 163.1),
            .mock(offset: -62, distance: 7.1, duration: 53.1),
            .mock(offset: -64, distance: 14.3, duration: 94.4),
            .mock(offset: -66, distance: 15.4, duration: 108.5),
            .mock(offset: -68, distance: 20.1, duration: 100.8),
            .mock(offset: -70, distance: 18.3, duration: 94.3),
            .mock(offset: -72, distance: 23.0, duration: 157.7),
            .mock(offset: -73, distance: 15.6, duration: 123.4),
            .mock(offset: -77, distance: 20.0, duration: 107.4),
            .mock(offset: -80, distance: 19.5, duration: 99.9),
            .mock(offset: -81, distance: 9.3, duration: 61.5),
            .mock(offset: -83, distance: 6.3, duration: 42.6),
            .mock(offset: -86, distance: 17.2, duration: 98.3),
            .mock(offset: -88, distance: 20.9, duration: 114.2),
            .mock(offset: -89, distance: 6.4, duration: 48.6),
            .mock(offset: -92, distance: 5.9, duration: 43.7),
            .mock(offset: -93, distance: 21.6, duration: 131.7),
            .mock(offset: -95, distance: 18.7, duration: 95.9),
            .mock(offset: -97, distance: 9.9, duration: 73.4),
            .mock(offset: -99, distance: 19.8, duration: 130.0),
            .mock(offset: -101, distance: 7.6, duration: 53.6),
            .mock(offset: -103, distance: 8.9, duration: 51.9),
            .mock(offset: -104, distance: 17.7, duration: 125.2),
            .mock(offset: -107, distance: 12.4, duration: 75.5),
            .mock(offset: -109, distance: 23.4, duration: 171.0),
            .mock(offset: -111, distance: 21.4, duration: 169.6),
            .mock(offset: -112, distance: 11.2, duration: 61.6),
            .mock(offset: -114, distance: 11.6, duration: 74.7),
            .mock(offset: -116, distance: 8.2, duration: 62.0),
            .mock(offset: -118, distance: 20.9, duration: 111.5),
            .mock(offset: -120, distance: 19.1, duration: 107.6),
            .mock(offset: -121, distance: 18.3, duration: 111.1),
            .mock(offset: -124, distance: 20.6, duration: 145.5),
            .mock(offset: -126, distance: 22.9, duration: 166.0),
            .mock(offset: -128, distance: 13.4, duration: 91.6),
            .mock(offset: -130, distance: 23.1, duration: 167.0),
            .mock(offset: -133, distance: 15.8, duration: 113.3),
            .mock(offset: -134, distance: 21.8, duration: 114.9),
            .mock(offset: -135, distance: 14.8, duration: 82.9),
            .mock(offset: -137, distance: 13.9, duration: 108.1),
            .mock(offset: -139, distance: 24.9, duration: 155.9),
            .mock(offset: -142, distance: 19.1, duration: 108.9),
            .mock(offset: -144, distance: 11.7, duration: 62.1),
            .mock(offset: -146, distance: 17.2, duration: 111.4),
            .mock(offset: -148, distance: 9.8, duration: 73.4),
            .mock(offset: -151, distance: 19.4, duration: 112.3),
            .mock(offset: -152, distance: 16.3, duration: 92.7),
            .mock(offset: -155, distance: 23.2, duration: 143.8),
            .mock(offset: -157, distance: 17.7, duration: 101.3),
            .mock(offset: -159, distance: 10.1, duration: 53.3),
            .mock(offset: -161, distance: 10.6, duration: 73.7),
            .mock(offset: -163, distance: 16.8, duration: 106.3),
            .mock(offset: -165, distance: 16.7, duration: 105.4),
            .mock(offset: -167, distance: 12.9, duration: 69.7),
            .mock(offset: -169, distance: 7.9, duration: 61.6),
            .mock(offset: -171, distance: 13.6, duration: 81.1),
            .mock(offset: -172, distance: 18.2, duration: 134.1),
            .mock(offset: -174, distance: 23.6, duration: 144.2),
            .mock(offset: -175, distance: 11.2, duration: 68.0),
            .mock(offset: -179, distance: 5.1, duration: 30.9),
            .mock(offset: -183, distance: 22.6, duration: 124.7),
            .mock(offset: -186, distance: 9.6, duration: 69.8),
            .mock(offset: -188, distance: 14.1, duration: 77.0),
            .mock(offset: -189, distance: 16.1, duration: 121.7),
            .mock(offset: -192, distance: 8.7, duration: 45.0),
            .mock(offset: -193, distance: 11.9, duration: 94.3),
            .mock(offset: -196, distance: 17.1, duration: 99.3),
            .mock(offset: -197, distance: 22.7, duration: 131.4),
            .mock(offset: -198, distance: 13.0, duration: 70.3),
            .mock(offset: -200, distance: 23.5, duration: 118.6),
            .mock(offset: -201, distance: 18.9, duration: 143.5),
            .mock(offset: -202, distance: 7.4, duration: 46.2),
            .mock(offset: -204, distance: 6.4, duration: 40.5),
            .mock(offset: -205, distance: 11.8, duration: 68.3),
            .mock(offset: -208, distance: 7.0, duration: 42.6),
            .mock(offset: -210, distance: 9.0, duration: 59.8),
            .mock(offset: -213, distance: 7.8, duration: 56.9),
            .mock(offset: -214, distance: 6.9, duration: 45.4),
            .mock(offset: -216, distance: 21.5, duration: 169.1),
            .mock(offset: -217, distance: 21.6, duration: 128.3),
            .mock(offset: -219, distance: 16.3, duration: 91.8),
            .mock(offset: -222, distance: 8.0, duration: 40.9),
            .mock(offset: -224, distance: 6.1, duration: 40.8),
            .mock(offset: -226, distance: 14.4, duration: 112.8),
            .mock(offset: -229, distance: 5.3, duration: 28.9),
            .mock(offset: -233, distance: 23.3, duration: 140.3),
            .mock(offset: -243, distance: 23.9, duration: 126.2),
            .mock(offset: -280, distance: 11.6, duration: 72.1),
            .mock(offset: -282, distance: 23.2, duration: 174.9),
            .mock(offset: -284, distance: 23.7, duration: 147.9),
            .mock(offset: -286, distance: 13.9, duration: 93.7),
            .mock(offset: -288, distance: 5.3, duration: 36.3),
            .mock(offset: -290, distance: 16.6, duration: 125.9),
            .mock(offset: -291, distance: 12.8, duration: 74.4),
            .mock(offset: -295, distance: 18.1, duration: 141.7),
            .mock(offset: -296, distance: 10.0, duration: 51.7),
            .mock(offset: -297, distance: 5.7, duration: 43.8),
            .mock(offset: -299, distance: 24.5, duration: 154.1),
            .mock(offset: -301, distance: 18.1, duration: 130.9),
            .mock(offset: -303, distance: 14.7, duration: 101.9),
            .mock(offset: -304, distance: 11.6, duration: 70.1),
            .mock(offset: -306, distance: 9.6, duration: 75.7),
            .mock(offset: -307, distance: 13.0, duration: 100.8),
            .mock(offset: -309, distance: 20.7, duration: 138.6),
            .mock(offset: -310, distance: 9.5, duration: 50.8),
            .mock(offset: -313, distance: 22.7, duration: 146.1),
            .mock(offset: -315, distance: 18.9, duration: 127.2),
            .mock(offset: -317, distance: 13.2, duration: 68.6),
            .mock(offset: -319, distance: 19.0, duration: 148.9),
            .mock(offset: -323, distance: 18.0, duration: 112.7),
            .mock(offset: -324, distance: 11.9, duration: 79.7),
            .mock(offset: -326, distance: 19.8, duration: 147.0),
            .mock(offset: -329, distance: 14.6, duration: 79.5),
            .mock(offset: -332, distance: 17.9, duration: 136.1),
            .mock(offset: -334, distance: 21.8, duration: 145.8),
            .mock(offset: -336, distance: 8.7, duration: 60.7),
            .mock(offset: -339, distance: 16.9, duration: 119.5),
            .mock(offset: -340, distance: 25.0, duration: 188.9),
            .mock(offset: -342, distance: 18.4, duration: 115.4),
            .mock(offset: -344, distance: 18.2, duration: 101.3),
            .mock(offset: -347, distance: 7.8, duration: 48.3),
            .mock(offset: -349, distance: 18.4, duration: 99.0),
            .mock(offset: -350, distance: 16.5, duration: 90.5),
            .mock(offset: -352, distance: 22.8, duration: 176.4),
            .mock(offset: -354, distance: 11.4, duration: 64.7),
            .mock(offset: -356, distance: 19.0, duration: 103.8),
            .mock(offset: -358, distance: 6.7, duration: 40.9),
            .mock(offset: -360, distance: 6.1, duration: 45.3),
            .mock(offset: -361, distance: 20.0, duration: 126.7),
            .mock(offset: -363, distance: 24.2, duration: 138.5),
            .mock(offset: -365, distance: 8.8, duration: 63.4),
            .mock(offset: -368, distance: 20.2, duration: 123.0),
            .mock(offset: -371, distance: 19.6, duration: 140.4),
            .mock(offset: -372, distance: 18.2, duration: 141.7),
            .mock(offset: -375, distance: 25.0, duration: 151.1),
            .mock(offset: -377, distance: 10.9, duration: 67.6),
            .mock(offset: -378, distance: 24.7, duration: 169.5),
            .mock(offset: -380, distance: 8.0, duration: 63.6),
            .mock(offset: -381, distance: 9.7, duration: 52.0),
            .mock(offset: -384, distance: 15.7, duration: 88.2),
            .mock(offset: -385, distance: 9.3, duration: 66.0),
            .mock(offset: -387, distance: 8.4, duration: 66.9),
            .mock(offset: -389, distance: 12.9, duration: 100.2),
            .mock(offset: -390, distance: 15.3, duration: 100.5),
            .mock(offset: -391, distance: 23.5, duration: 183.8),
            .mock(offset: -392, distance: 13.8, duration: 76.7),
            .mock(offset: -394, distance: 8.1, duration: 47.3),
            .mock(offset: -395, distance: 19.5, duration: 147.6),
            .mock(offset: -397, distance: 6.6, duration: 33.4),
            .mock(offset: -400, distance: 7.0, duration: 48.3),
        ]
    }()

    static func screenshots(unit: UnitLength = .kilometers) -> [Run] {
        @Dependency(\.date) var date
        @Dependency(\.calendar) var calendar

        func randomPace() -> Double {
            if unit == .kilometers {
                return .random(in: 5 ..< 7)
            } else {
                return .random(in: 8 ..< 11)
            }
        }

        func randomDistance() -> Double {
            if unit == .kilometers {
                return .random(in: 6 ..< 10)
            } else {
                return .random(in: 3 ..< 5)
            }
        }

        let runsThisWeek: [Run] = [
            .mock(offset: 0, distance: 5.5, pace: randomPace(), unit: unit), // Sun 18th
            .mock(offset: -1, distance: 7.2, pace: randomPace(), unit: unit), // Sat 17th
            .mock(offset: -2, distance: 10, pace: randomPace(), unit: unit), // Fri 16th
            .mock(offset: -4, distance: 5.01, pace: randomPace(), unit: unit), // Wed 14th
            .mock(offset: -6, distance: 12.2, pace: randomPace(), unit: unit), // Mon 12th
        ]

        let startOfScreenshotYear = Date(timeIntervalSince1970: 1_672_574_400) // 01/01/2023
        let numberOfDaysRemaining = calendar.dateComponents([.day], from: startOfScreenshotYear, to: date.now).day ?? 0
        var runsInYear: [Run] = []
        var offset = 2
        while offset < numberOfDaysRemaining {
            runsInYear.append(
                .mock(offset: -6 - offset, distance: randomDistance(), pace: randomPace(), unit: unit)
            )
            offset += 2
        }

        return runsThisWeek + runsInYear
    }
}

public extension Run {
    static func content(_ name: String) -> Run {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else { return .mock() }
        guard let data = try? Data(contentsOf: url) else { return .mock() }
        guard let run = try? JSONDecoder().decode(Run.self, from: data) else { return .mock() }
        return run
    }
}
