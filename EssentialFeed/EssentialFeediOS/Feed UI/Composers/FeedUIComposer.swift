//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 27/09/2023.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func composeUIWith(feedLoader: FeedLoader, imageLoader: ImageLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(loader: feedLoader)
        let refreshController = FeedRefreshViewController(loadFeed: presentationAdapter.load)
        let feedController = FeedViewController(refreshController: refreshController)
        
        presentationAdapter.presenter = FeedRefreshPresenter(
            feedView: FeedImagePresentationAdapter(controller: feedController, loader: imageLoader),
            loadingView: WeakRefProxy(refreshController)
        )
        
        return feedController
    }
}
