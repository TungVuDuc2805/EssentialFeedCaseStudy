//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 28/09/2023.
//

import Foundation

public protocol FeedLoadingView {
    func display(_ model: FeedLoadingViewModel)
}

public protocol FeedView {
    func display(_ model: FeedViewModel)
}

public final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    static var title: String {
        return "My Feed"
    }
    
    public init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    public func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didEndLoadingFeed(with feed: [FeedImage]) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        feedView.display(FeedViewModel(feed: feed))
    }
    
    public func didEndLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
