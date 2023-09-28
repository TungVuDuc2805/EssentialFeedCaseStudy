//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 28/09/2023.
//

import EssentialFeed

final class FeedLoaderPresentationAdapter {
    private let loader: FeedLoader
    var presenter: FeedRefreshPresenter?

    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func load() {
        presenter?.didStartLoadingFeed()
        loader.load { [weak self] result in
            switch result {
            case .success(let images):
                self?.presenter?.didEndLoadingFeed(with: images)
            case .failure(let error):
                self?.presenter?.didEndLoadingFeed(with: error)
            }
        }
    }
}
