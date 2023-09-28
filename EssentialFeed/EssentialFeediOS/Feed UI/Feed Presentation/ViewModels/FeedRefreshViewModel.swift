//
//  FeedRefreshViewModel.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 27/09/2023.
//

import Foundation
import EssentialFeed

final class FeedRefreshViewModel {
    private let loader: FeedLoader
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    var onFeedLoadingState: ((Bool) -> Void)?
    var onLoadedFeed: (([FeedImage]) -> Void)?

    func load() {
        onFeedLoadingState?(true)
        loader.load { [weak self] result in
            switch result {
            case .success(let images):
                self?.onLoadedFeed?(images)
            case .failure:
                break
            }
            self?.onFeedLoadingState?(false)
        }
    }
}
