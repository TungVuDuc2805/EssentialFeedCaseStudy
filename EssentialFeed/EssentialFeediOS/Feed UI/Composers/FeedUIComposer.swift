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
        let presenter = FeedRefreshPresenter(
            feedView: adapter,
            loadingView: WeakRefProxy(refreshController)
        )
        let presentationAdapter = FeedLoaderPresntationAdapter(loader: feedLoader, presenter: presenter)

        refreshController.loadFeed = presentationAdapter.load
        
         let controller = FeedViewController(refreshController: refreshController)
        adapter.controller = controller
        
        return controller
    }
}

private final class WeakRefProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ model: FeedLoadingViewModel) {
        object?.display(model)
    }
}

private final class FeedImagePresentationAdapter: FeedView {
    weak var controller: FeedViewController?
    private let loader: ImageLoader
    
    init(loader: ImageLoader) {
        self.loader = loader
    }
    
    func display(_ model: FeedViewModel) {
        controller?.feed = model.feed.map {
            let viewModel = FeedImageCellViewModel(model: $0, imageLoader: loader)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}

private final class FeedLoaderPresntationAdapter {
    private let loader: FeedLoader
    private let presenter: FeedRefreshPresenter

    init(loader: FeedLoader, presenter: FeedRefreshPresenter) {
        self.loader = loader
        self.presenter = presenter
    }
    
    func load() {
        presenter.didStartLoadingFeed()
        loader.load { [weak self] result in
            switch result {
            case .success(let images):
                self?.presenter.didEndLoadingFeed(with: images)
            case .failure(let error):
                self?.presenter.didEndLoadingFeed(with: error)
            }
        }
    }
}
