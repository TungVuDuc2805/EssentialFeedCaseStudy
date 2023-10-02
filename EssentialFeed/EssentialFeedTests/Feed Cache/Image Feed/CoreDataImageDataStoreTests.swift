//
//  CoreDataImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 03/10/2023.
//

import XCTest
import EssentialFeed

class CoreDataImageDataStoreTests: XCTestCase {
    
    func test_retrieve_deliversNotFoundOnEmptyCache() {
        let sut = makeSUT()
        
        let capturedError = retrieveError(from: sut, with: anyURL())

        XCTAssertEqual(capturedError, .notFound)
    }
    
    func test_retrieve_deliversNotFoundOnNotMatchURL() {
        let sut = makeSUT()
        let url0 = URL(string: "https://url-0.com")!
        let url1 = URL(string: "https://url-1.com")!
        let imageData = anyData()
        
        insertError(to: sut, with: url0, data: imageData)

        let capturedError = retrieveError(from: sut, with: url1)
        
        XCTAssertEqual(capturedError, .notFound)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        XCTAssertEqual(retrieveErrorTwice(from: sut, with: anyURL()), .notFound)
    }
    
    func test_retrieve_deliversCachedImageDataWithURL() {
        let sut = makeSUT()
        let url = URL(string: "https://url-0.com")!
        let imageData = anyData()
        let exp = expectation(description: "wait for completion")
        
        insertError(to: sut, with: url, data: imageData)
        
        var capturedData: Data?
        sut.retrieve(from: url) { result in
            switch result {
            case .success(let data):
                capturedData = data
            default:
                break
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(capturedData, imageData)
    }
 
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insertError(to sut: CoreDataFeedStore, with url: URL, data: Data, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for completion")
        let items = [LocalFeedImage(id: UUID(), description: nil, location: nil, url: url)]
        
        var capturedError: Error?
        sut.insert(items, Date()) { insertionError in
            if let error = insertionError {
                XCTFail("expected insert successfully but got \(error) instead", file: file, line: line)
            }
            
            sut.insert(data, with: url) { error in
                capturedError = error
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 0.1)
        return capturedError
    }
    
    private func retrieveError(from sut: CoreDataFeedStore, with url: URL) -> CoreDataFeedStore.ImageDataStoreError? {
        let exp = expectation(description: "wait for completion")
        
        var capturedError: CoreDataFeedStore.ImageDataStoreError?
        sut.retrieve(from: url) { result in
            switch result {
            case .failure(let error as CoreDataFeedStore.ImageDataStoreError?):
                capturedError = error
            default:
                break
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        return capturedError
    }
    
    private func retrieveErrorTwice(from sut: CoreDataFeedStore, with url: URL) -> CoreDataFeedStore.ImageDataStoreError? {
        _ = retrieveError(from: sut, with: url)
        return retrieveError(from: sut, with: url)
    }
    
}
