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
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        let presentationAdapter = FeedLoaderPresentationAdapter(loader: feedLoader)
        let refreshController = FeedRefreshViewController(loadFeed: presentationAdapter.load)
        feedController.refreshController = refreshController
        
        presentationAdapter.presenter = FeedRefreshPresenter(
            feedView: FeedImagePresentationAdapter(controller: feedController, loader: imageLoader),
            loadingView: WeakRefProxy(refreshController)
        )
        
        return feedController
    }
}
