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
    
    enum Error: Swift.Error {
        case clientError
        case invalidData
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.clientError)
            }
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
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataTwice_requestsLoadFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageData_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedError: RemoteImageDataLoader.Error?
        sut.loadImageData(from: anyURL()) {
            capturedError = $0
        }
        
        client.completeWithError()
        
        XCTAssertEqual(capturedError, .clientError)
    }
    
    func test_loadImageData_deliversErrorOnNon200HTTPClientError() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            assert(sut, toCompleteWithError: .invalidData) {
                let data = Data("image data".utf8)
                client.completeWith(data: data, statusCode: code, at: index)
            }
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func assert(_ sut: RemoteImageDataLoader, toCompleteWithError error: RemoteImageDataLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedErrors = [RemoteImageDataLoader.Error]()
        sut.loadImageData(from: anyURL()) { error in
            capturedErrors.append(error)
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
            messages[index].completion(.success((data, response)))
        }
    }
    
}
