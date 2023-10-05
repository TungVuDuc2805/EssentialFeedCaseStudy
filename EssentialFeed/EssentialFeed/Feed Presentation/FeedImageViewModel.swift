//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let descriptionText: String?
    public let locationText: String?
    public let isLoading: Bool
    public let imageData: Image?
    
    public var isLocationHidden: Bool {
        locationText == nil
    }
    
    public var isRetryButtonHidden: Bool {
        imageData != nil || isLoading
    }
    
    public init(descriptionText: String?, locationText: String?, isLoading: Bool, imageData: Image?) {
        self.descriptionText = descriptionText
        self.locationText = locationText
        self.isLoading = isLoading
        self.imageData = imageData
    }
}
