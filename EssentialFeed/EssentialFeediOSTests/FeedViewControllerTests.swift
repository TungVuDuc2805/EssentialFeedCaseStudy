//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Tung Vu Duc on 26/09/2023.
//

import XCTest

class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
    
}

class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadFeedCallCount, 0)
    }
    
    // MARK: - Helpers
    class LoaderSpy {
        private(set) var loadFeedCallCount: Int = 0
        
    }
    
}
