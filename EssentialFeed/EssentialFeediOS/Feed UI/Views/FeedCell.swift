//
//  FeedCell.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 26/09/2023.
//

import UIKit

public final class FeedCell: UITableViewCell {
    public let contentContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let locationContainer = UIView()
    public let feedImageView = UIImageView()
    var retry: (() -> Void)?
    public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        return button
    }()
    
    @objc func handleRetry() {
        retry?()
    }
}
