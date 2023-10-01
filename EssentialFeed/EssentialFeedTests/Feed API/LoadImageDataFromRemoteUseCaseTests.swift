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
    
    private class Task: Cancellable {
        var completion: ((Result<Data, Swift.Error>) -> Void)?
        
        init(completion: @escaping (Result<Data, Swift.Error>) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            completion = nil
        }
        
        func handle(_ result: Result<(Data, HTTPURLResponse), Swift.Error>) {
            switch result {
            case .success(let (data, response)):
                guard response.statusCode == 200 else {
                    completion?(.failure(Error.invalidData))
                    return
                }
                completion?(.success(data))
            case .failure:
                completion?(.failure(Error.clientError))
            }
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void) -> Cancellable {
        let task = Task(completion: completion)
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            task.handle(result)
        }
        
        return task
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
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataTwice_requestsLoadFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageData_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        assert(sut, toCompleteWithError: .clientError) {
            client.completeWithError()
        }
    }
    
    func test_loadImageData_deliversErrorOnNon200HTTPClientError() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            assert(sut, toCompleteWithError: .invalidData) {
                let data = Data("any image data".utf8)
                client.completeWith(data: data, statusCode: code, at: index)
            }
        }
    }
    
    func test_loadImageData_deliversLoadedImageDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let data = Data("any image data".utf8)

        var capturedImageData: Data?
        _ =  sut.loadImageData(from: anyURL()) { result in
            if let data = try? result.get() {
                capturedImageData = data
            }
        }
        
        client.completeWith(data: data, statusCode: 200)
        
        XCTAssertEqual(capturedImageData, data)
    }
    
    func test_cancelLoadImageData_doesNotDeliversResult() {
        let (sut, client) = makeSUT()

        var capturedResult: Result<Data,Error>?
        let task = sut.loadImageData(from: anyURL()) { result in
            capturedResult = result
        }
        
        task.cancel()
        client.completeWithError()
        
        XCTAssertNil(capturedResult)
    }
    
    func test_loadImageData_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteImageDataLoader? = RemoteImageDataLoader(client: client)

        var capturedResult: Result<Data,Error>?
        _ = sut?.loadImageData(from: anyURL()) { result in
            capturedResult = result
        }
        
        sut = nil
        client.completeWithError()

        XCTAssertNil(capturedResult)
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
        _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case .failure(let error as RemoteImageDataLoader.Error):
                capturedErrors.append(error)
            default:
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
            messages[index].completion(.success((data, response)))
        }
    }
    
}
