//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 13/09/2023.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
