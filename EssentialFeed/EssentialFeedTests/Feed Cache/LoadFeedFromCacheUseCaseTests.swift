//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.messages, [])
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private class FeedStoreSpy: FeedStore {
        enum Messages: Equatable {
            case deletion
            case insertion(items: [LocalFeedImage], timestamp: Date)
        }
        
        var messages = [Messages]()
        var deletionCompletions = [(Error?) -> Void]()
        var insertionCompletions = [(Error?) -> Void]()

        func deleteCachedFeed(completion: @escaping (Error?) -> Void) {
            messages.append(.deletion)
            deletionCompletions.append(completion)
        }
        
        func completeDeletionWith(_ error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ items: [LocalFeedImage], _ timestamp: Date, completion: @escaping (Error?) -> Void) {
            messages.append(.insertion(items: items, timestamp: timestamp))
            insertionCompletions.append(completion)
        }
        
        func completeInsertionWith(_ error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }
    
}
