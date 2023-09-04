@testable import Repository
import XCTest

@MainActor
final class RepositorySourceTests: XCTestCase {
    func testCacheHelperReturnsCorrectValue() {
        let cacheInput: Int = .random(in: 1 ..< 10000)
        let cacheResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Int, Int> = .init(
            cache: {
                XCTAssertEqual($0, cacheInput)
                return cacheResult
            },
            remote: { _ in .random(in: 1 ..< 10000) }
        )

        let response = sut.cache(input: cacheInput)
        XCTAssertEqual(response, cacheResult)
    }

    func testRemoteHelperReturnsCorrectValue() async throws {
        let remoteInput: Int = .random(in: 1 ..< 10000)
        let remoteResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Int, Int> = .init(
            cache: { _ in nil },
            remote: {
                XCTAssertEqual($0, remoteInput)
                return remoteResult
            }
        )

        let response = try await sut.remote(input: remoteInput)
        XCTAssertEqual(response, remoteResult)
    }

    func testRemoteHelperForwardsErrorOnFailure() async throws {
        let remoteError: NSError = .init(domain: #fileID, code: #line)

        let sut: RepositorySource<Int, Int> = .init(
            cache: { _ in nil },
            remote: { _ in throw remoteError }
        )

        do {
            let response = try await sut.remote(input: .random(in: 1 ..< 10000))
            XCTFail("Unexpected success: \(response)")
        } catch {
            XCTAssertEqual(error as NSError, remoteError)
        }
    }

    func testStreamWhenCacheIsAvailable() async throws {
        let input: Int = .random(in: 1 ..< 10000)
        let cacheResult: Int = .random(in: 1 ..< 10000)
        let remoteResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Int, Int> = .init(
            cache: {
                XCTAssertEqual($0, input)
                return cacheResult
            },
            remote: {
                XCTAssertEqual($0, input)
                return remoteResult
            }
        )

        var values: [Int] = []
        for try await value in sut.stream(input: input) {
            values.append(value)
        }

        XCTAssertEqual(values, [cacheResult, remoteResult])
    }

    func testStreamWhenNoCacheIsAvailable() async throws {
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

        XCTAssertEqual(values, [remoteResult])
    }

    func testStreamWhenRemoteRequestFails() async throws {
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
            XCTFail("Unexpected successful response(s): \(values)")

        } catch {
            XCTAssertEqual(error as NSError, remoteError)
        }

        XCTAssertEqual(values, [])
    }

    func testCacheOrRemoteWhenCacheIsPresent() async throws {
        let cacheResult: Int = .random(in: 1 ..< 10000)
        let remoteResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Void, Int> = .init(
            cache: { cacheResult },
            remote: { remoteResult }
        )

        let result = try await sut.cacheOrRemote()
        XCTAssertEqual(result, cacheResult)
    }

    func testCacheOrRemoteWhenCacheIsNotPresent() async throws {
        let remoteResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Void, Int> = .init(
            cache: { nil },
            remote: { remoteResult }
        )

        let result = try await sut.cacheOrRemote()
        XCTAssertEqual(result, remoteResult)
    }

    func testVoidInputHelpers() async throws {
        let cacheResult: Int = .random(in: 1 ..< 10000)
        let remoteResult: Int = .random(in: 1 ..< 10000)

        let sut: RepositorySource<Void, Int> = .init(
            cache: { cacheResult },
            remote: { remoteResult }
        )

        XCTAssertEqual(sut.cache(), cacheResult)
        let remote = try await sut.remote()
        XCTAssertEqual(remote, remoteResult)

        var values: [Int] = []
        for try await value in sut.stream() {
            values.append(value)
        }

        XCTAssertEqual(values, [cacheResult, remoteResult])
    }
}
