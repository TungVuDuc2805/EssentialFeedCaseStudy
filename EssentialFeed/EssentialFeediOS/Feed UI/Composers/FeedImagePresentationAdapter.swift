//
//  FeedImagePresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 28/09/2023.
//

import UIKit

final class FeedImagePresentationAdapter: FeedView {
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
