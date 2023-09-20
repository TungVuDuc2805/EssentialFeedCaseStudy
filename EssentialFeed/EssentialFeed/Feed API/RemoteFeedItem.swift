//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
    var toModel: FeedImage {
        FeedImage(id: id, description: description, location: location, imageURL: image)
    }
}
