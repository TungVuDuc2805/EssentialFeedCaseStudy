//
//  LoadImageDataFromLocalTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 02/10/2023.
//

import XCTest

class ImageDataStore {
    enum Message: Equatable {
        case deletion(URL)
        case insertion(Data, URL)
    }
    var messages = [Message]()
    var deletionCompletions = [(Error?) -> Void]()
    var insertionCompletions = [(Error?) -> Void]()

    func deleteImageData(with url: URL, completion: @escaping (Error?) -> Void) {
        messages.append(.deletion(url))
        deletionCompletions.append(completion)
    }
    
    func completeDeletionWith(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ image: Data, with url: URL, completion: @escaping (Error?) -> Void) {
        messages.append(.insertion(image, url))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
}

class LocalImageDataLoader {
    private let store: ImageDataStore
    init(store: ImageDataStore) {
        self.store = store
    }
    
    func save(_ imageData: Data, with url: URL, completion: @escaping (Error?) -> Void) {
        store.deleteImageData(with: url) { [unowned self] deletionError in
            guard deletionError == nil else {
                return completion(deletionError)
            }
            store.insert(imageData, with: url, completion: completion)
        }
    }
}

class LoadImageDataFromLocalTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, storeSpy) = makeSUT()

        XCTAssertTrue(storeSpy.messages.isEmpty)
    }
    
    func test_save_requestsStoreDeletion() {
        let (sut, storeSpy) = makeSUT()
        let url = anyURL()
        
        sut.save(anyData(), with: url) { _ in }
        
        XCTAssertEqual(storeSpy.messages, [.deletion(url)])
    }
    
    func test_save_doesNotRequestsStoreInsertionOnDeletionError() {
        let (sut, storeSpy) = makeSUT()
        let url = anyURL()
        
        sut.save(anyData(), with: url) { _ in }
        
        storeSpy.completeDeletionWith(anyNSError())
        
        XCTAssertEqual(storeSpy.messages, [.deletion(url)])
    }
    
    func test_save_deliversErrorOnDeletionError() {
        let (sut, storeSpy) = makeSUT()
        let deletionError = anyNSError()
        
        var capturedError: Error?
        sut.save(anyData(), with: anyURL()) {
            capturedError = $0
        }
        
        storeSpy.completeDeletionWith(deletionError)
        
        XCTAssertEqual(capturedError as NSError?, deletionError)
    }
    
    func test_save_requestsStoreInsertionOnDeletionSuccessfully() {
        let (sut, storeSpy) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, with: url) { _ in }
        
        storeSpy.completeDeletionSuccessfully()
        
        XCTAssertEqual(storeSpy.messages, [.deletion(url), .insertion(data, url)])
    }
    
    func test_save_deliversErrorOnInsertionError() {
        let (sut, storeSpy) = makeSUT()
        let insertionError = anyNSError()
        let url = anyURL()
        let data = anyData()
        
        var capturedError: Error?
        sut.save(data, with: url) {
            capturedError = $0
        }
        
        storeSpy.completeDeletionSuccessfully()
        storeSpy.completeInsertion(with: anyNSError())

        XCTAssertEqual(capturedError as NSError?, insertionError)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalImageDataLoader, storeSpy: ImageDataStore) {
        let storeSpy = ImageDataStore()
        let sut = LocalImageDataLoader(store: storeSpy)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(storeSpy, file: file, line: line)
        
        return (sut, storeSpy)
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
}
