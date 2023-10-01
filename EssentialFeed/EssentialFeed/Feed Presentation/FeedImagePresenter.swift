//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 28/09/2023.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<Image, View: FeedImageView> where View.Image == Image {
    private let view: View
    private let transformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.transformer = imageTransformer
    }
    
    private struct InvalidImageDataError: Error {}
        
    public func didStartLoadingImage(_ model: FeedImage) {
        view.display(FeedImageViewModel(
            descriptionText: model.description,
            locationText: model.location,
            isLoading: true,
            imageData: nil)
        )
    }
    
    public func didEndLoadingImage(with error: Error, model: FeedImage) {
        view.display(FeedImageViewModel(
            descriptionText: model.description,
            locationText: model.location,
            isLoading: false,
            imageData: nil)
        )
    }
    
    public func didEndLoadingImage(with imageData: Data, model: FeedImage) {
        guard let image = transformer(imageData) else {
            return didEndLoadingImage(with: InvalidImageDataError(), model: model)
        }
        view.display(FeedImageViewModel(
            descriptionText: model.description,
            locationText: model.location,
            isLoading: false,
            imageData: image)
        )
    }
}
