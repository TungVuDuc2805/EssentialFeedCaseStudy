//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import XCTest
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ model: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ model: FeedViewModel)
}

class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didEndLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didEndLoadingFeed(with feed: [FeedImage]) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        feedView.display(FeedViewModel(feed: feed))
    }

}

class FeedPresenterTests: XCTestCase {
    
    func test_didStartLoadingFeed_sendMessageToView() {
        let loadingView = FeedLoadingViewSpy()
        let sut = FeedPresenter(feedView: loadingView, loadingView: loadingView)
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(loadingView.messages, [.loading(true)])
    }
    
    func test_didEndLoadingFeedWithError_sendMessageToView() {
        let loadingView = FeedLoadingViewSpy()
        let sut = FeedPresenter(feedView: loadingView, loadingView: loadingView)
        
        sut.didEndLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(loadingView.messages, [.loading(false)])
    }
    
    func test_didEndLoadingFeedWithFeed_sendMessageToView() {
        let loadingView = FeedLoadingViewSpy()
        let sut = FeedPresenter(feedView: loadingView, loadingView: loadingView)
        let feed = anyUniqueItems().models
        
        sut.didEndLoadingFeed(with: feed)
        
        XCTAssertEqual(loadingView.messages, [.loading(false), .feed(feed)])
    }
    
    // MARK: - Helpers
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
