import Foundation

public struct RepositorySource<Input, Model>: Sendable {
    public var _cache: @Sendable (Input) -> Model?
    public var _remote: @Sendable (Input) async throws -> Model

    public init(
        cache: @Sendable @escaping (Input) -> Model?,
        remote: @Sendable @escaping (Input) async throws -> Model
    ) {
        _cache = cache
        _remote = remote
    }
}

public extension RepositorySource {
    func cache(input: Input) -> Model? {
        _cache(input)
    }

    func remote(input: Input) async throws -> Model {
        try await _remote(input)
    }

    func stream(input: Input) -> AsyncThrowingStream<Model, Error> {
        .init { continuation in
            if let cache = cache(input: input) {
                continuation.yield(cache)
            }

            Task {
                do {
                    let remote = try await remote(input: input)
                    continuation.yield(remote)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func cacheOrRemote(input: Input) async throws -> Model {
        if let cache = cache(input: input) {
            return cache
        } else {
            return try await remote(input: input)
        }
    }
}

public extension RepositorySource {
    static func mock(
        value: Model,
        delay: Double? = nil
    ) -> Self {
        .init(
            cache: { _ in value },
            remote: { _ in
                if let delay {
                    try await Task.sleep(for: .seconds(delay))
                }
                return value
            }
        )
    }
}
