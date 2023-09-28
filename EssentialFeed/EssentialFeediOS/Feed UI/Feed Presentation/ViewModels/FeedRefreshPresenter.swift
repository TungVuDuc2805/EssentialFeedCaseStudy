//
//  FeedRefreshPresenter.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 28/09/2023.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
    func display(_ isLoading: Bool)
}

protocol FeedView {
    func display(with feed: [FeedImage])
}

final class FeedRefreshPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let loader: FeedLoader
    
    init(feedView: FeedView, loadingView: FeedLoadingView, loader: FeedLoader) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.loader = loader
    }
    
    var onFeedLoadingState: ((Bool) -> Void)?
    var onLoadedFeed: (([FeedImage]) -> Void)?

    func load() {
        loadingView.display(true)
        loader.load { [weak self] result in
            switch result {
            case .success(let images):
                self?.feedView.display(with: images)
            case .failure:
                break
            }
            self?.loadingView.display(false)
        }
    }
}
