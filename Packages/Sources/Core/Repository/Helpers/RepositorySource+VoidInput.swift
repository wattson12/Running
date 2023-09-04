import Foundation

public extension RepositorySource where Input == Void {
    func cache() -> Model? {
        _cache(())
    }

    func remote() async throws -> Model {
        try await _remote(())
    }

    func stream() -> AsyncThrowingStream<Model, Error> {
        stream(input: ())
    }

    func cacheOrRemote() async throws -> Model {
        try await cacheOrRemote(input: ())
    }
}
