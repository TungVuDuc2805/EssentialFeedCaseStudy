//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 13/09/2023.
//

import XCTest
import EssentialFeed

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
        
        assert(sut, toCompleteWithError: .connectivity) {
            client.completeWithError()
        }
    }
    
    func test_load_deliversError_onNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            assert(sut, toCompleteWithError: .invalidData) {
                client.completeWith(statusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversError_on200HTTPResponseInvalidJSON() {
        let (sut, client) = makeSUT()
            
        let data = Data("invalid json data".utf8)
        assert(sut, toCompleteWithError: .invalidData) {
            client.completeWith(data: data, statusCode: 200)
        }
    }
    
    func test_load_deliversEmptyFeed_on200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        let json: [String: [FeedItem]] = [
            "items": []
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        
        assert(sut, toCompleteWithItems: []) {
            client.completeWith(data: data, statusCode: 200)
        }
    }
    
    func test_load_deliversFeedItems_on200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(id: UUID(), description: "any description", location: "any location", imageURL: URL(string: "image-1")!)
        
        let item1JSON = [
            "id": item1.id.uuidString,
            "description": item1.description!,
            "location": item1.location!,
            "image": item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "image-2")!)
        
        let item2JSON = [
            "id": item2.id.uuidString,
            "image": item2.imageURL.absoluteString
        ]
        
        let json = [
            "items": [item1JSON, item2JSON]
        ]
        
        let data = try! JSONSerialization.data(withJSONObject: json)
        assert(sut, toCompleteWithItems: [item1, item2]) {
            client.completeWith(data: data, statusCode: 200)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "any-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private func assert(_ sut: RemoteFeedLoader, toCompleteWithItems items: [FeedItem], when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var capturedFeed: [FeedItem]?
        sut.load { result in
            switch result {
            case .success(let feed):
                capturedFeed = feed
            case .failure:
                break
            }
        }
        
        action()
        
        XCTAssertEqual(capturedFeed, items)
    }
    
    private func assert(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { result in
            switch result {
            case .failure(let error):
                capturedErrors.append(error)
            case .success:
                break
            }
        }
        
        action()
        
        XCTAssertEqual(capturedErrors, [error], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func completeWithError(at index: Int = 0) {
            let error = NSError(domain: "test", code: 0)
            messages[index].completion(.failure(error))
        }
        
        func completeWith(data: Data = Data(), statusCode code: Int = 200, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
    
}
