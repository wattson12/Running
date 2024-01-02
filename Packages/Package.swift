// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static let composableArchitecture: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let dependencies: Self = .product(name: "Dependencies", package: "swift-dependencies")
    static let dependenciesMacros: Self = .product(name: "DependenciesMacros", package: "swift-dependencies")
    static let dependenciesAdditions: Self = .product(name: "DependenciesAdditions", package: "swift-dependencies-additions")
    static let urlRouting: Self = .product(name: "URLRouting", package: "swift-url-routing")
}

extension Product {
    static func library(name: String) -> Product {
        .library(name: name, targets: [name])
    }
}

extension String {
    // App
    static let app: Self = "App"
    
    // Core
    static let cache: Self = "Cache"
    static let designSystem: Self = "DesignSystem"
    static let model: Self = "Model"
    static let repository: Self = "Repository"
    static let resources: Self = "Resources"
    
    static func core(_ package: String) -> Self {
        "Sources/Core/\(package)"
    }

    // Dependencies
    static let healthKitServiceInterface: Self = "HealthKitServiceInterface"
    static let healthKitServiceLive: Self = "HealthKitServiceLive"
    static let widgets: Self = "Widgets"
    static let logging: Self = "Logging"
    static let featureFlags: Self = "FeatureFlags"
    
    static func dependencies(_ package: String) -> Self {
        "Sources/Dependencies/\(package)"
    }
    
    // Features
    static let goals: Self = "Goals"
    static let goalList: Self = "GoalList"
    static let editGoal: Self = "EditGoal"
    static let goalDetail: Self = "GoalDetail"
    
    static let permissions: Self = "Permissions"

    static let runs: Self = "Runs"
    static let runList: Self = "RunList"
    static let runDetail: Self = "RunDetail"
    
    static let settings: Self = "Settings"
    
    static let history: Self = "History"
    
    static func feature(_ name: String, in domain: String? = nil) -> Self {
        ["Sources", "Features", domain, name].compactMap { $0 }.joined(separator: "/")
    }
    
    // Tests
    var tests: String { self + "Tests" }
    static func coreTests(_ package: String) -> Self {
        "Tests/Core/\(package)Tests"
    }
    static func dependenciesTests(_ package: String) -> Self {
        "Tests/Dependencies/\(package)Tests"
    }
    static func featureTests(_ name: String, in domain: String? = nil) -> Self {
        ["Tests", "Features", domain, name + "Tests"].compactMap { $0 }.joined(separator: "/")
    }
}

let package = Package(
    name: "Packages",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: .app),
        .library(name: .permissions),
        .library(name: .runList),
        .library(name: .runDetail),
        .library(name: .goalList),
        .library(name: .editGoal),
        .library(name: .goalDetail),
        .library(name: .settings),
        .library(name: .history),
        .library(name: .repository),
        .library(name: .resources),
        .library(name: .healthKitServiceInterface),
        .library(name: .healthKitServiceLive),
        .library(name: .widgets),
        .library(name: .logging),
        .library(name: .featureFlags),
        .library(name: .cache),
        .library(name: .model),
        .library(name: .designSystem),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "observation-beta"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/tgrapperon/swift-dependencies-additions", from: "1.0.1"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing", from: "0.6.0"),
    ],
    targets: [
        .target(
            name: .runList,
            dependencies: [
                .composableArchitecture,
                .dependenciesAdditions,
                .target(name: .runDetail),
                .target(name: .model),
                .target(name: .repository),
                .target(name: .designSystem),
                .target(name: .widgets),
                .target(name: .featureFlags),
            ],
            path: .feature(.runList, in: .runs)
        ),
        .target(
            name: .runDetail,
            dependencies: [
                .composableArchitecture,
                .dependenciesAdditions,
                .target(name: .model),
                .target(name: .repository),
                .target(name: .designSystem),
                .target(name: .featureFlags),
            ],
            path: .feature(.runDetail, in: .runs)
        ),
        .target(
            name: .model,
            dependencies: [
                .dependencies,
                .target(name: .resources),
            ],
            path: .core(.model)
        ),
        .target(
            name: .healthKitServiceInterface,
            dependencies: [
                .dependencies,
                .dependenciesMacros,
                .target(name: .model),
            ],
            path: .dependencies(.healthKitServiceInterface)
        ),
        .target(
            name: .healthKitServiceLive,
            dependencies: [
                .target(name: .healthKitServiceInterface),
                .dependencies,
                .dependenciesAdditions,
            ],
            path: .dependencies(.healthKitServiceLive)
        ),
        .target(
            name: .widgets,
            dependencies: [
                .dependencies,
                .dependenciesMacros,
            ],
            path: .dependencies(.widgets)
        ),
        .target(
            name: .logging,
            dependencies: [
                .composableArchitecture,
                .dependencies
            ],
            path: .dependencies(.logging)
        ),
        .target(
            name: .featureFlags,
            dependencies: [
                .dependencies,
                .dependenciesAdditions,
                .dependenciesMacros,
            ],
            path: .dependencies(.featureFlags)
        ),
        .target(
            name: .app,
            dependencies: [
                .composableArchitecture,
                .urlRouting,
                .target(name: .model),
                .target(name: .runList),
                .target(name: .goalList),
                .target(name: .permissions),
                .target(name: .settings),
                .target(name: .history),
            ]
        ),
        .target(
            name: .repository,
            dependencies: [
                .dependencies,
                .dependenciesMacros,
                .target(name: .model),
                .target(name: .healthKitServiceInterface),
                .target(name: .cache),
            ],
            path: .core(.repository)
        ),
        .target(
            name: .resources,
            path: .core(.resources),
            resources: [
                .process("Colors/Colors.xcassets")
            ]
        ),
        .target(
            name: .cache,
            dependencies: [
                .dependencies,
                .dependenciesMacros,
                
            ],
            path: .core(.cache)
        ),
        .target(
            name: .goalList,
            dependencies: [
                .composableArchitecture,
                .dependencies,
                .target(name: .model),
                .target(name: .repository),
                .target(name: .editGoal),
                .target(name: .goalDetail),
                .target(name: .designSystem),
                .target(name: .widgets),
            ],
            path: .feature(.goalList, in: .goals)
        ),
        .target(
            name: .editGoal,
            dependencies: [
                .composableArchitecture,
                .dependencies,
                .target(name: .model),
                .target(name: .repository),
                .target(name: .designSystem),
            ],
            path: .feature(.editGoal, in: .goals)
        ),
        .target(
            name: .goalDetail,
            dependencies: [
                .composableArchitecture,
                .dependencies,
                .target(name: .model),
                .target(name: .repository),
                .target(name: .runList),
                .target(name: .designSystem),
            ],
            path: .feature(.goalDetail, in: .goals)
        ),
        .target(
            name: .settings,
            dependencies: [
                .composableArchitecture,
                .dependencies,
                .dependenciesAdditions,
                .target(name: .designSystem),
                .target(name: .logging),
                .target(name: .featureFlags),
                .target(name: .cache),
            ],
            path: .feature(.settings)
        ),
        .target(
            name: .history,
            dependencies: [
                .composableArchitecture,
                .dependencies,
                .dependenciesAdditions,
                .target(name: .designSystem),
                .target(name: .logging),
                .target(name: .featureFlags),
                .target(name: .repository),
                .target(name: .model),
                .target(name: .cache),
            ],
            path: .feature(.history)
        ),
        .target(
            name: .permissions,
            dependencies: [
                .composableArchitecture,
                .dependencies,
                .target(name: .model),
                .target(name: .repository),
                .target(name: .designSystem),
            ],
            path: .feature(.permissions)
        ),
        .target(
            name: .designSystem,
            dependencies: [
                .target(name: .resources),
            ],
            path: .core(.designSystem)
        ),
        // Tests
        .testTarget(
            name: .app.tests,
            dependencies: [.byName(name: .app)]
        ),
        .testTarget(
            name: .model.tests,
            dependencies: [.byName(name: .model)],
            path: .coreTests(.model)
        ),
        .testTarget(
            name: .repository.tests,
            dependencies: [.byName(name: .repository)],
            path: .coreTests(.repository)
        ),
        .testTarget(
            name: .healthKitServiceInterface.tests,
            dependencies: [.byName(name: .healthKitServiceInterface)],
            path: .dependenciesTests(.healthKitServiceInterface)
        ),
        .testTarget(
            name: .healthKitServiceLive.tests,
            dependencies: [.byName(name: .healthKitServiceLive)],
            path: .dependenciesTests(.healthKitServiceLive)
        ),
        .testTarget(
            name: .editGoal.tests,
            dependencies: [.byName(name: .editGoal)],
            path: .featureTests(.editGoal, in: .goals)
        ),
        .testTarget(
            name: .goalDetail.tests,
            dependencies: [.byName(name: .goalDetail)],
            path: .featureTests(.goalDetail, in: .goals)
        ),
        .testTarget(
            name: .goalList.tests,
            dependencies: [.byName(name: .goalList)],
            path: .featureTests(.goalList, in: .goals)
        ),
        .testTarget(
            name: .permissions.tests,
            dependencies: [.byName(name: .permissions)],
            path: .featureTests(.permissions)
        ),
        .testTarget(
            name: .runList.tests,
            dependencies: [.byName(name: .runList)],
            path: .featureTests(.runList)
        ),
        .testTarget(
            name: .runDetail.tests,
            dependencies: [.byName(name: .runDetail)],
            path: .featureTests(.runDetail)
        ),
        .testTarget(
            name: .settings.tests,
            dependencies: [.byName(name: .settings)],
            path: .featureTests(.settings)
        ),
        .testTarget(
            name: .history.tests,
            dependencies: [.byName(name: .history)],
            path: .featureTests(.history)
        ),
    ]
)
