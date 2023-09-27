//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 27/09/2023.
//

import Foundation
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func composeUIWith(feedLoader: FeedLoader, imageLoader: ImageLoader) -> FeedViewController {
        
        let feedRefreshViewModel = FeedRefreshViewModel(loader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedRefreshViewModel)
        let controller = FeedViewController(refreshController: refreshController)
        
        feedRefreshViewModel.onLoadedFeed = adaptFeedToCellControllers(forwardingTo: controller, loader: imageLoader)
        return controller
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: ImageLoader) -> ([FeedImage]) -> Void {
        { [weak controller] models in
            controller?.feed = models.map {
                let viewModel = FeedImageCellViewModel(model: $0, imageLoader: loader)
                return FeedImageCellController(viewModel: viewModel)
            }
        }
    }
}
