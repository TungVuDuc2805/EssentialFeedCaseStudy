//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 13/09/2023.
//

import XCTest

protocol HTTPClient {
    
}

class RemoteFeedLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
    }
    
}
