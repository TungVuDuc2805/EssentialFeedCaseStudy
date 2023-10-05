//
//  WeakRefProxy.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 28/09/2023.
//

import UIKit
import EssentialFeed

final class WeakRefProxy<T: AnyObject> {
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

extension WeakRefProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}
