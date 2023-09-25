//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Tung Vu Duc on 25/09/2023.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        cleanCacheArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cleanCacheArtifacts()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.load { result in
            switch result {
            case .success(let feed):
                XCTAssertEqual(feed, [])
            case .failure(let error):
                XCTFail("Expect successfully feed result, but got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnSeparatedInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = anyUniqueItems()
        
        let exp1 = expectation(description: "wait for completion")
        let exp2 = expectation(description: "wait for completion")

        sutToPerformSave.save(feed.models) { error in
            XCTAssertNil(error)
            exp1.fulfill()
        }
        
        wait(for: [exp1], timeout: 1.0)
        
        sutToPerformLoad.load { result in
            switch result {
            case .success(let receivedFeed):
                XCTAssertEqual(feed.models, receivedFeed)
            case .failure(let error):
                XCTFail("Expect successfully feed result, but got \(error) instead")
            }
            exp2.fulfill()
        }
        
        wait(for: [exp2], timeout: 1.0)
    }

    // MARK: - Helpers
    private func makeSUT(url: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let store = CodableFeedStore(url: storeURL())
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)

        return sut
    }
    
    private func storeURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cleanCacheArtifacts() {
        try? FileManager.default.removeItem(at: storeURL())
    }

}
