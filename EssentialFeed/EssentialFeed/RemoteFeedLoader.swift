//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 14/09/2023.
//

import Foundation

public class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void = { _ in }) {
        client.get(from: url) { result in
            switch result {
            case .failure:
                completion(.failure(.connectivity))
            case .success(let data, let response):
                if let feedItems = try? FeedItemsMapper.map(data, response) {
                    completion(.success(feedItems))
                } else {
                    completion(.failure(.invalidData))
                }
            }
        }
    }
}
