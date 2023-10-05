//
//  LoadImageDataFromRemoteUseCaseTests.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import XCTest
import EssentialFeed

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
    
}
