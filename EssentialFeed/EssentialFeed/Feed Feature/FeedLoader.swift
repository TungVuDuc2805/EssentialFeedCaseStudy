//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 13/09/2023.
//

import Foundation

public protocol FeedLoader {
    typealias LoadFeedResult = Result<[FeedImage], Error>
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
