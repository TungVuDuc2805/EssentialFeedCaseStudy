//
//  LoadImageDataFromLocalTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 02/10/2023.
//

import XCTest

class ImageDataStore {
    var messages = [Any]()
}

class LocalImageDataLoader {
    private let store: ImageDataStore
    init(store: ImageDataStore) {
        self.store = store
    }
}

class LoadImageDataFromLocalTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let storeSpy = ImageDataStore()
        _ = LocalImageDataLoader(store: storeSpy)
        
        XCTAssertTrue(storeSpy.messages.isEmpty)
    }
    
}
