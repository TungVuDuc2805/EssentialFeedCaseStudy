//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 13/09/2023.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
