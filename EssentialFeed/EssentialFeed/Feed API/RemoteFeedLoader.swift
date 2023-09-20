//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 14/09/2023.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case .success(let data, let response):
                completion(self.map(data, from: response))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        if let feedItems = try? FeedItemsMapper.map(data, response) {
            return .success(feedItems.feed)
        } else {
            return .failure(Error.invalidData)
        }
    }
}

extension Array where Element == RemoteFeedItem {
    var feed: [FeedItem] {
        self.map { $0.toModel }
    }
}
