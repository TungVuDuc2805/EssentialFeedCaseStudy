//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {
    
    func test_didStartLoadingFeed_sendMessageToView() {
        let (sut, viewSpy) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(viewSpy.messages, [.loading(true)])
    }
    
    func test_didEndLoadingFeedWithError_sendMessageToView() {
        let (sut, viewSpy) = makeSUT()
        
        sut.didEndLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(viewSpy.messages, [.loading(false)])
    }
    
    func test_didEndLoadingFeedWithFeed_sendMessageToView() {
        let (sut, viewSpy) = makeSUT()
        let feed = anyUniqueItems().models
        
        sut.didEndLoadingFeed(with: feed)
        
        XCTAssertEqual(viewSpy.messages, [.loading(false), .feed(feed)])
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: FeedLoadingViewSpy) {
        let loadingView = FeedLoadingViewSpy()
        let sut = FeedPresenter(feedView: loadingView, loadingView: loadingView)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadingView, file: file, line: line)
            
        return (sut, loadingView)
    }
    
    private class FeedLoadingViewSpy: FeedLoadingView, FeedView {
        enum Message: Equatable {
            case loading(Bool)
            case feed([FeedImage])
        }
        var messages = [Message]()
        
        func display(_ model: FeedLoadingViewModel) {
            messages.append(.loading(model.isLoading))
        }
        
        func display(_ model: FeedViewModel) {
            messages.append(.feed(model.feed))
        }
    }
    
}
