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
        
        let refreshController = FeedRefreshViewController(loader: feedLoader)
        let controller = FeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: controller, loader: imageLoader)
        return controller
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: ImageLoader) -> ([FeedImage]) -> Void {
        { [weak controller] models in
            controller?.feed = models.map {
                FeedImageCellController(model: $0, imageLoader: loader)
            }
        }
    }
}
