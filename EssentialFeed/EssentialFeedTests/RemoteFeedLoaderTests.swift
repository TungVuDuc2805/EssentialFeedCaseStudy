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
                client.completeWith(data: emptyJSONData(), statusCode: code, at: index)
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
        
        assert(sut, toCompleteWithItems: []) {
            client.completeWith(data: emptyJSONData(), statusCode: 200)
        }
    }
    
    func test_load_deliversFeedItems_on200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let (item1, item1JSON) = makeItem(description: "any description", location: "any location", image: URL(string: "image-1")!)
        let (item2, item2JSON) = makeItem(id: UUID(), description: nil, location: nil, image: URL(string: "image-2")!)
        
        let data = makeItemsJSON([item1JSON, item2JSON])
       
        assert(sut, toCompleteWithItems: [item1, item2]) {
            client.completeWith(data: data, statusCode: 200)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: URL(string: "any-url.com")!, client: client)
        
        var capturedResult: RemoteFeedLoader.Result?
        sut?.load { capturedResult = $0 }
        
        sut = nil
        client.completeWith(data: emptyJSONData())
        
        XCTAssertNil(capturedResult)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated.Potential memory leaks.", file: file, line: line)
        }
    }
    
    private func emptyJSONData() -> Data {
        let json: [String: [FeedItem]] = [
            "items": []
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeItem(
        id: UUID = UUID(),
        description: String? = "any description",
        location: String? = "any location",
        image: URL
    ) -> (model: FeedItem, json: [String: String]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: image)
        
        let itemJSON = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, itemJSON)
    }
    
    func makeItemsJSON(_ json: [[String: String]]) -> Data {
        let json = [
            "items": json
        ]

        return try! JSONSerialization.data(withJSONObject: json)
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
