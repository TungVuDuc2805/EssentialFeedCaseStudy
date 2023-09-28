//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 28/09/2023.
//

import Foundation
import EssentialFeed

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
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
