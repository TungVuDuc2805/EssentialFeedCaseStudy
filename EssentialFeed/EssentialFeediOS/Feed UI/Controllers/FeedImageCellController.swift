//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 27/09/2023.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    private lazy var cell = FeedCell()
    private let delegate: FeedImageCellControllerDelegate
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }

    func view() -> FeedCell {
        loadImage()
        return cell
    }
    
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell.descriptionLabel.text = model.descriptionText
        cell.locationLabel.text = model.locationText
        cell.locationContainer.isHidden = model.isLocationHidden
        cell.feedImageView.image = model.imageData
        cell.retryButton.isHidden = model.isRetryButtonHidden
        cell.contentContainer.isShimmering = model.isLoading
        cell.retry = delegate.didRequestImage
    }
    
    func loadImage() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
}
