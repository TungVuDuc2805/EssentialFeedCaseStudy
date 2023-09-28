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
        
        let adapter = FeedImagePresentationAdapter(loader: imageLoader)
        let refreshController = FeedRefreshViewController()
        let presenter = FeedRefreshPresenter(feedView: adapter, loadingView: refreshController, loader: feedLoader)
        refreshController.presenter = presenter
        let controller = FeedViewController(refreshController: refreshController)
        adapter.controller = controller
        
        return controller
    }
}

private final class FeedImagePresentationAdapter: FeedView {
    weak var controller: FeedViewController?
    private let loader: ImageLoader
    
    init(loader: ImageLoader) {
        self.loader = loader
    }
    
    func display(with feed: [FeedImage]) {
        controller?.feed = feed.map {
            let viewModel = FeedImageCellViewModel(model: $0, imageLoader: loader)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}
