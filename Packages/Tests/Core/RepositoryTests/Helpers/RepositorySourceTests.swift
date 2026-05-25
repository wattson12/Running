@testable import Repository
import Testing
import Foundation

@MainActor
@Suite
struct RepositorySourceTests {
    @Test func cacheHelperReturnsCorrectValue() {
        let cacheInput: Int = .random(in: 1 ..< 10000)
        let cacheResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Int, Int> = .init(
            cache: {
                #expect($0 == cacheInput)
                return cacheResult
            },
            remote: { _ in .random(in: 1 ..< 10000) }
        )

        let response = sut.cache(input: cacheInput)
        #expect(response == cacheResult)
    }

    @Test func remoteHelperReturnsCorrectValue() async throws {
        let remoteInput: Int = .random(in: 1 ..< 10000)
        let remoteResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Int, Int> = .init(
            cache: { _ in nil },
            remote: {
                #expect($0 == remoteInput)
                return remoteResult
            }
        )

        let response = try await sut.remote(input: remoteInput)
        #expect(response == remoteResult)
    }

    @Test func remoteHelperForwardsErrorOnFailure() async throws {
        let remoteError: NSError = .init(domain: #fileID, code: #line)

        let sut: RepositorySource<Int, Int> = .init(
            cache: { _ in nil },
            remote: { _ in throw remoteError }
        )

        do {
            let response = try await sut.remote(input: .random(in: 1 ..< 10000))
            Issue.record("Unexpected success: \(response)")
        } catch {
            #expect(error as NSError == remoteError)
        }
    }

    @Test func streamWhenCacheIsAvailable() async throws {
        let input: Int = .random(in: 1 ..< 10000)
        let cacheResult: Int = .random(in: 1 ..< 10000)
        let remoteResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Int, Int> = .init(
            cache: {
                #expect($0 == input)
                return cacheResult
            },
            remote: {
                #expect($0 == input)
                return remoteResult
            }
        )

        var values: [Int] = []
        for try await value in sut.stream(input: input) {
            values.append(value)
        }

        #expect(values == [cacheResult, remoteResult])
    }

    @Test func streamWhenNoCacheIsAvailable() async throws {
        let input: Int = .random(in: 1 ..< 10000)
        let remoteResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Int, Int> = .init(
            cache: { _ in nil },
            remote: { _ in remoteResult }
        )

        var values: [Int] = []
        for try await value in sut.stream(input: input) {
            values.append(value)
        }

        #expect(values == [remoteResult])
    }

    @Test func streamWhenRemoteRequestFails() async throws {
        let input: Int = .random(in: 1 ..< 10000)
        let remoteError: NSError = .init(domain: #fileID, code: #line)

        let sut: RepositorySource<Int, Int> = .init(
            cache: { _ in nil },
            remote: { _ in throw remoteError }
        )

        var values: [Int] = []
        do {
            for try await value in sut.stream(input: input) {
                values.append(value)
            }
            Issue.record("Unexpected successful response(s): \(values)")

        } catch {
            #expect(error as NSError == remoteError)
        }

        #expect(values == [])
    }

    @Test func cacheOrRemoteWhenCacheIsPresent() async throws {
        let cacheResult: Int = .random(in: 1 ..< 10000)
        let remoteResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Void, Int> = .init(
            cache: { cacheResult },
            remote: { remoteResult }
        )

        let result = try await sut.cacheOrRemote()
        #expect(result == cacheResult)
    }

    @Test func cacheOrRemoteWhenCacheIsNotPresent() async throws {
        let remoteResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Void, Int> = .init(
            cache: { nil },
            remote: { remoteResult }
        )

        let result = try await sut.cacheOrRemote()
        #expect(result == remoteResult)
    }

    @Test func voidInputHelpers() async throws {
        let cacheResult: Int = .random(in: 1 ..< 10000)
        let remoteResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Void, Int> = .init(
            cache: { cacheResult },
            remote: { remoteResult }
        )

        #expect(sut.cache() == cacheResult)
        let remote = try await sut.remote()
        #expect(remote == remoteResult)

        var values: [Int] = []
        for try await value in sut.stream() {
            values.append(value)
        }

        #expect(values == [cacheResult, remoteResult])
    }
}
