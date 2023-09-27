//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 27/09/2023.
//

import Foundation
import EssentialFeed

final class FeedImageCellViewModel {
    private let imageLoader: ImageLoader
    private var task: Cancellable?
    private let model: FeedImage
    
    init(model: FeedImage, imageLoader: ImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var onLoadImageState: ((Bool) -> Void)?
    var onLoadedImageData: ((Data?) -> Void)?
    
    var descriptionText: String? {
        return model.description
    }
    
    var locationText: String? {
        return model.location
    }
    
    var hasLocation: Bool {
        return model.location != nil
    }
    
    func loadImageData() {
        onLoadImageState?(true)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.onLoadedImageData?(try? result.get())
            self?.onLoadImageState?(false)
        }
    }
    
    func cancelTask() {
        task?.cancel()
    }
}
