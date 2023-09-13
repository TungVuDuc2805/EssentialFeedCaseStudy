//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 13/09/2023.
//

import XCTest

protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPURLResponse?, Error?) -> Void)
}

class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Error) -> Void = { _ in }) {
        client.get(from: url) { _, error in
            if error != nil {
                completion(.connectivity)
            } else {
                completion(.invalidData)
            }
        }
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "any-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "any-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        sut.load()

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversError_onClientError() {
        let (sut, client) = makeSUT()

        var capturedError: RemoteFeedLoader.Error?
        sut.load {
            capturedError = $0
        }
        
        client.completeWithError()
        
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    func test_load_deliversError_onNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        var capturedError: RemoteFeedLoader.Error?
        sut.load {
            capturedError = $0
        }
        
        client.completeWith(statusCode: 300)
        
        XCTAssertEqual(capturedError, .invalidData)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "any-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPURLResponse?, Error?) -> Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPURLResponse?, Error?) -> Void) {
            messages.append((url, completion))
        }
        
        func completeWithError(at index: Int = 0) {
            let error = NSError(domain: "test", code: 0)
            messages[index].completion(nil, error)
        }
        
        func completeWith(statusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)
            
            messages[index].completion(response, nil)
        }
    }
    
}
