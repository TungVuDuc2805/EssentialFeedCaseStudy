//
//  FeedRefreshPresenter.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 28/09/2023.
//

import Foundation
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
        loadingView.display(FeedLoadingViewModel(isLoading: true))
        loader.load { [weak self] result in
            switch result {
            case .success(let images):
                self?.feedView.display(FeedViewModel(feed: images))
            case .failure:
                break
            }
            self?.loadingView.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
