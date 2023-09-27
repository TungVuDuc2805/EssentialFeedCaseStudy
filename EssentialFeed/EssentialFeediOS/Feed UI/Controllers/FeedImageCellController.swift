//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 27/09/2023.
//

import UIKit

final class FeedImageCellController {
    private var task: Cancellable?
    private let viewModel: FeedImageCellViewModel
    lazy var view = binded(FeedCell())
    
    init(viewModel: FeedImageCellViewModel) {
        self.viewModel = viewModel
    }
    
    private func binded(_ cell: FeedCell) -> UITableViewCell {
        cell.descriptionLabel.text = viewModel.descriptionText
        cell.locationLabel.text = viewModel.locationText
        cell.locationContainer.isHidden = !viewModel.hasLocation
        
        viewModel.onLoadImageState = { [weak cell] isLoading in
            cell?.contentContainer.isShimmering = isLoading
            if isLoading {
                cell?.feedImageView.image = nil
                cell?.retryButton.isHidden = true
            }
        }
        
        viewModel.onLoadedImageData = { [weak cell] data in
            let image = data.map(UIImage.init) ?? nil
            cell?.feedImageView.image = image
            cell?.retryButton.isHidden = image != nil
        }
        
        viewModel.loadImageData()
        
        cell.retry = viewModel.loadImageData
        
        return cell
    }
    
    func loadImage() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelTask()
    }
    
}
