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
        let presentationAdapter = FeedLoaderPresentationAdapter(loader: MainQueueDispatchingDecorator(decoratee: feedLoader))
        let feedController = FeedViewController.makeWith(loadFeed: presentationAdapter.load, title: FeedPresenter.title)
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedImagePresentationAdapter(
                controller: feedController,
                loader: MainQueueDispatchingDecorator(decoratee: imageLoader)
            ),
            loadingView: WeakRefProxy(feedController)
        )
        
        return feedController
    }
}

extension FeedViewController {
    static func makeWith(loadFeed: @escaping () -> Void, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.loadFeed = loadFeed
        feedController.title = title
        
        return feedController
    }
}
