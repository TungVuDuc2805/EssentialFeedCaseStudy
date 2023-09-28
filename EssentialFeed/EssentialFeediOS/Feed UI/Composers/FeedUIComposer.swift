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
    
    init(controller: FeedViewController, loader: ImageLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ model: FeedViewModel) {
        controller?.feed = model.feed.map {
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefProxy<FeedImageCellController>, UIImage>(loader: loader, model: $0)
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefProxy(view),
                imageTransformer: UIImage.init
            )
            
            return view
        }
    }
}

extension WeakRefProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

private final class FeedLoaderPresentationAdapter {
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

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let loader: ImageLoader
    private let model: FeedImage
    private var task: Cancellable?
    var presenter: FeedImagePresenter<Image, View>?

    init(loader: ImageLoader, model: FeedImage) {
        self.loader = loader
        self.model = model
    }
    
    func didRequestImage() {
        let model = model
        presenter?.didStartLoadingImage(model)
        task = loader.loadImageData(from: model.url) { [weak presenter] result in
            switch result {
            case .success(let data):
                presenter?.didEndLoadingImage(with: data, model: model)
            case .failure(let error):
                presenter?.didEndLoadingImage(with: error, model: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
}
