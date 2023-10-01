//
//  LoadImageDataFromRemoteUseCaseTests.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import XCTest
import EssentialFeed

class RemoteImageDataLoader {
    private let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL) {
        client.get(from: url) { _ in
            
        }
    }

}

class LoadImageDataFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotLoadImage() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_loadImageData_requestsLoadFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://any-url.com")!
        
        sut.loadImageData(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
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
            messages[index].completion(.success((data, response)))
        }
    }
    
}
