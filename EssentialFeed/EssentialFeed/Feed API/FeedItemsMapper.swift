//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import Foundation

internal class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
        
        var feed: [FeedItem] {
            items.map { $0.toModel }
        }
    }

    private struct RemoteFeedItem: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var toModel: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    private static var OK_200: Int {
        return 200
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.feed
    }
}
