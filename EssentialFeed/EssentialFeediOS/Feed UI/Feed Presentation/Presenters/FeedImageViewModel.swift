//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import Foundation

struct FeedImageViewModel<Image> {
    let descriptionText: String?
    let locationText: String?
    let isLoading: Bool
    let imageData: Image?
    
    var isLocationHidden: Bool {
        locationText == nil
    }
    
    var isRetryButtonHidden: Bool {
        imageData != nil || isLoading
    }
}
