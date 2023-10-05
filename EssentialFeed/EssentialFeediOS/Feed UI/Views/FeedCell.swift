//
//  FeedCell.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 26/09/2023.
//

import UIKit

public final class FeedCell: UITableViewCell {
    @IBOutlet public weak var contentContainer: UIView!
    @IBOutlet public weak var locationLabel: UILabel!
    @IBOutlet public weak var descriptionLabel: UILabel!
    @IBOutlet public weak var locationContainer: UIView!
    @IBOutlet public weak var feedImageView: UIImageView!
    var retry: (() -> Void)?
    @IBOutlet public weak var retryButton: UIButton!
    
    @IBAction func handleRetry() {
        retry?()
    }
}
