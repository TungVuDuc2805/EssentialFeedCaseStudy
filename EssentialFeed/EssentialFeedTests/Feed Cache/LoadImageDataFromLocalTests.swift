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
    }
    var messages = [Message]()
    var deletionCompletions = [(Error?) -> Void]()
    
    func deleteImageData(with url: URL, completion: @escaping (Error?) -> Void) {
        messages.append(.deletion(url))
        deletionCompletions.append(completion)
    }
    
    func completeDeletionWith(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
}

class LocalImageDataLoader {
    private let store: ImageDataStore
    init(store: ImageDataStore) {
        self.store = store
    }
    
    func save(_ imageData: Data, with url: URL) {
        store.deleteImageData(with: url) { _ in
            
        }
    }
}

class LoadImageDataFromLocalTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let storeSpy = ImageDataStore()
        _ = LocalImageDataLoader(store: storeSpy)
        
        XCTAssertTrue(storeSpy.messages.isEmpty)
    }
    
    func test_save_requestsStoreDeletion() {
        let storeSpy = ImageDataStore()
        let sut = LocalImageDataLoader(store: storeSpy)
        let url = anyURL()
        
        sut.save(Data("any".utf8), with: url)
        
        XCTAssertEqual(storeSpy.messages, [.deletion(url)])
    }
    
    func test_save_doesNotRequestsStoreInsertionOnDeletionError() {
        let storeSpy = ImageDataStore()
        let sut = LocalImageDataLoader(store: storeSpy)
        let url = anyURL()
        
        sut.save(Data("any".utf8), with: url)
        
        storeSpy.completeDeletionWith(anyNSError())
        
        XCTAssertEqual(storeSpy.messages, [.deletion(url)])
    }
    
}
