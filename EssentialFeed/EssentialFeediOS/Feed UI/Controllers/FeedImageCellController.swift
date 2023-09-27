//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 27/09/2023.
//

import UIKit
import EssentialFeed

final class FeedImageCellController {
    private var task: Cancellable?
    private let model: FeedImage
    private let imageLoader: ImageLoader
    
    init(model: FeedImage, imageLoader: ImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedCell()
        cell.contentContainer.isShimmering = true
        cell.descriptionLabel.text = model.description
        cell.locationLabel.text = model.location
        cell.locationContainer.isHidden = model.location == nil
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        
        let imageLoad = { [weak self, weak cell] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadImageData(from: model.url) { result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.retryButton.isHidden = image != nil
                cell?.contentContainer.isShimmering = false
            }
        }
        
        imageLoad()
        
        cell.retry = imageLoad
        
        return cell
    }
    
    func cancelLoad() {
        task?.cancel()
    }
    
}
