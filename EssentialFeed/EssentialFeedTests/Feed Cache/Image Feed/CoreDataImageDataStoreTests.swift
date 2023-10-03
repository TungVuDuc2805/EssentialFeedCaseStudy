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
        
        insertError(to: sut, with: url, data: imageData)
        
        var capturedData: Data?
        let result = retrieveResult(from: sut, with: url)
        switch result {
        case .success(let data):
            capturedData = data
        default:
            break
        }
        
        XCTAssertEqual(capturedData, imageData)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let url = URL(string: "https://url-0.com")!
        let imageData = anyData()
        
       XCTAssertNil(insertError(to: sut, with: url, data: imageData))
    }
    
    func test_insert_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let url = URL(string: "https://url-0.com")!
        let imageData = anyData()
        
        insertError(to: sut, with: url, data: imageData)
        
        XCTAssertNil(insertError(to: sut, with: url, data: imageData))
    }
    
    func test_insert_overridesPreviouslyInserted() {
        let sut = makeSUT()
        let url = URL(string: "https://url-0.com")!
        let firstData = Data("first".utf8)
        let lastData = Data("last".utf8)

        insertError(to: sut, with: url, data: firstData)
        insertError(to: sut, with: url, data: lastData)
        
        var capturedData: Data?
        let result = retrieveResult(from: sut, with: url)
        switch result {
        case .success(let data):
            capturedData = data
        default:
            break
        }
        
        XCTAssertEqual(capturedData, lastData)
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
        var capturedError: CoreDataFeedStore.ImageDataStoreError?
        let result = retrieveResult(from: sut, with: url)
        
        switch result {
        case .failure(let error as CoreDataFeedStore.ImageDataStoreError?):
            capturedError = error
        default:
            break
        }
        
        return capturedError
    }
    
    private func retrieveResult(from sut: CoreDataFeedStore, with url: URL) -> ImageDataStore.RetrievalResult? {
        let exp = expectation(description: "wait for completion")
        
        var capturedResult: ImageDataStore.RetrievalResult?
        sut.retrieve(from: url) { result in
            capturedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        return capturedResult
    }
    
    private func retrieveErrorTwice(from sut: CoreDataFeedStore, with url: URL) -> CoreDataFeedStore.ImageDataStoreError? {
        _ = retrieveError(from: sut, with: url)
        return retrieveError(from: sut, with: url)
    }
    
}
