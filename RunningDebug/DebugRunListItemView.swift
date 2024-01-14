import ComposableArchitecture
import HealthKit
import HealthKitServiceInterface
import Model
import Repository
import SwiftUI

struct DebugRunListItemFeature: Reducer {
    struct State: Equatable, Identifiable {
        let run: Run
        var isLoading: Bool = false

        var id: Run.ID {
            run.id
        }
    }

    enum Action: Equatable {
        enum View: Equatable {
            case onAppear
            case cachedButtonTapped
            case remoteButtonTapped
        }

        enum Internal: Equatable {
            case detailFetched(TaskResult<WorkoutDetail>)
            case runDetailFetched(TaskResult<Run>)
        }

        case view(View)
        case _internal(Internal)
    }

    @Dependency(\.healthKit.runningWorkouts) var healthKit
    @Dependency(\.repository.runningWorkouts) var repository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let ._internal(action):
                return _internal(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            return .none
        case .cachedButtonTapped:
            guard !state.isLoading else { return .none }
            state.isLoading = true
            return .run { [id = state.run.id] send in
                let result = await TaskResult {
                    try await repository.detail(for: id)
                }
                await send(._internal(.runDetailFetched(result)))
            }
        case .remoteButtonTapped:
            state.isLoading = true
            return .run { [id = state.run.id] send in
                let result = await TaskResult {
                    try await healthKit.detail(for: id)
                }
                await send(._internal(.detailFetched(result)))
            }
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> EffectOf<Self> {
        switch action {
        case let .detailFetched(.success(detail)):
            state.isLoading = false
            print("healthkit", detail.locations.count)
            print("healthkit", detail.samples.count)
            return .none
        case let .detailFetched(.failure(error)):
            state.isLoading = false
            print("healthkit", error)
            return .none
        case let .runDetailFetched(.success(run)):
            state.isLoading = false
//            print("repository", run.detail?.locations.count)
//            print("repository", run.detail?.distanceSamples.count)
            guard let _samples = run.detail?.distanceSamples else { return .none }
            let samples = _samples.sorted(by: { $0.startDate < $1.startDate })
            print("-----")
            print("public extension [DistanceSample] {")
            print("    static var preview: [DistanceSample] {")
            print("        [")
            for (index, sample) in samples.enumerated() {
                guard index % 2 == 0 else { continue }
                print("            .init(startDate: Date(timeIntervalSinceReferenceDate: \(sample.startDate.timeIntervalSinceReferenceDate)), distance: .init(value: \(sample.distance.converted(to: .meters).value), unit: .meters)),")
            }
            print("        ]")
            print("    }")
            print("}")
//            public extension DistanceSample {
//                static var preview: [DistanceSample] {
//                    [
//                        .init(startDate: Date(), distance: .init(value: 1, unit: .meters))
//                    ]
//                }
//            }
            return .none
        case let .runDetailFetched(.failure(error)):
            print("repository", error)
            state.isLoading = false
            return .none
        }
    }
}

struct DebugRunListItemView: View {
    let store: StoreOf<DebugRunListItemFeature>

    var body: some View {
        WithViewStore(
            store,
            observe: { $0 },
            send: DebugRunListItemFeature.Action.view
        ) { viewStore in
            HStack {
                VStack(alignment: .leading) {
                    Text(viewStore.run.distance.formatted())

                    HStack {
//                        Text(viewStore.run.locations.count.description)
                        Text(viewStore.run.detail?.distanceSamples.count.description ?? "-")
                    }
                    .font(.caption2)
                }

                Spacer()

                Button("Cached") { viewStore.send(.cachedButtonTapped) }
//                Button("Remote") { viewStore.send(.remoteButtonTapped) }

                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}

#Preview {
    DebugRunListItemView(
        store: .init(
            initialState: .init(run: .mock()),
            reducer: DebugRunListItemFeature.init
        )
    )
}
