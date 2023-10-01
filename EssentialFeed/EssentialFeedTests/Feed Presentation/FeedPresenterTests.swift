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

class FeedPresenter {
    private let loadingView: FeedLoadingView
    init(loadingView: FeedLoadingView) {
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
    }

}

class FeedPresenterTests: XCTestCase {
    
    func test_didStartLoadingFeed_sendMessageToView() {
        let loadingView = FeedLoadingViewSpy()
        let sut = FeedPresenter(loadingView: loadingView)
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(loadingView.messages, [.loading(true)])
    }
    
    func test_didEndLoadingFeedWithError_sendMessageToView() {
        let loadingView = FeedLoadingViewSpy()
        let sut = FeedPresenter(loadingView: loadingView)
        
        sut.didEndLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(loadingView.messages, [.loading(false)])
    }
    
    func test_didEndLoadingFeedWithFeed_sendMessageToView() {
        let loadingView = FeedLoadingViewSpy()
        let sut = FeedPresenter(loadingView: loadingView)
        
        sut.didEndLoadingFeed(with: [])
        
        XCTAssertEqual(loadingView.messages, [.loading(false)])
    }
    
    // MARK: - Helpers
    private class FeedLoadingViewSpy: FeedLoadingView {
        enum Message: Equatable {
            case loading(Bool)
        }
        var messages = [Message]()
        
        func display(_ model: FeedLoadingViewModel) {
            messages.append(.loading(model.isLoading))
        }
    }
    
}
