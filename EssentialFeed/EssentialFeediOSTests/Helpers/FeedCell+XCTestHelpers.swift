//
//  FeedCell+XCTestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Tung Vu Duc on 30/09/2023.
//

import Foundation
import EssentialFeediOS
import UIKit

extension FeedCell {
    var isShowingImageLoadingIndicator: Bool {
        return contentContainer.isShimmering
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
    
    var isRetryButtonVisible: Bool {
        return !retryButton.isHidden
    }
    
    func simulateRetry() {
        retryButton.simulateTap()
    }
}
