import ComposableArchitecture
import HealthKit
import HealthKitServiceInterface
import Model
import Repository
import SwiftUI

@Reducer
struct DebugRunListItemFeature: Reducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let run: Run
        var isLoading: Bool = false

        var id: Run.ID {
            run.id
        }
    }

    @CasePathable
    enum Action: Equatable, ViewAction {
        @CasePathable
        enum View: Equatable {
            case onAppear
            case cachedButtonTapped
            case remoteButtonTapped
        }

        @CasePathable
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

            logJSON(for: run)

            return .none
        case let .runDetailFetched(.failure(error)):
            print("repository", error)
            state.isLoading = false
            return .none
        }
    }

    private func logJSON(for run: Run) {
        var run = run
        if var detail = run.detail, !detail.locations.isEmpty {
            let samples = detail.locations.sorted(by: { $0.timestamp < $1.timestamp })

            let referenceCoordinate = Location.Coordinate(
                latitude: -32.91829430734193,
                longitude: 151.7259057948816
            )

            let startingCoordinate = samples[0]
            let latitudeOffset = startingCoordinate.coordinate.latitude - referenceCoordinate.latitude
            let longitudeOffset = startingCoordinate.coordinate.longitude - referenceCoordinate.longitude

            func obfuscateCoordinate(_ coordinate: Location.Coordinate) -> Location.Coordinate {
                .init(
                    latitude: coordinate.latitude - latitudeOffset,
                    longitude: coordinate.longitude - longitudeOffset
                )
            }

            let obfuscatedSamples = samples.map { location in
                Location(
                    coordinate: obfuscateCoordinate(location.coordinate),
                    altitude: location.altitude,
                    timestamp: location.timestamp
                )
            }
            detail.locations = obfuscatedSamples
            run.detail = detail
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        guard let data = try? encoder.encode(run) else { return }
        guard let json = String(data: data, encoding: .utf8) else { return }
        print(json)
    }
}

@ViewAction(for: DebugRunListItemFeature.self)
struct DebugRunListItemView: View {
    let store: StoreOf<DebugRunListItemFeature>

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(store.run.distance.formatted())

                HStack {
//                        Text(viewStore.run.locations.count.description)
                    Text(store.run.detail?.distanceSamples.count.description ?? "-")
                }
                .font(.caption2)
            }

            Spacer()

            Button("Cached") { send(.cachedButtonTapped) }
//                Button("Remote") { viewStore.send(.remoteButtonTapped) }

            if store.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .onAppear { send(.onAppear) }
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
