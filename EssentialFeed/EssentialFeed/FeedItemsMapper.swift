//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import Foundation

internal class FeedItemsMapper {
    struct Root: Decodable {
        let items: [RemoteFeedItem]
        
        var feed: [FeedItem] {
            items.map { $0.toModel }
        }
    }

    struct RemoteFeedItem: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var toModel: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return root.feed
        }
        
        throw RemoteFeedLoader.Error.invalidData
    }
}
