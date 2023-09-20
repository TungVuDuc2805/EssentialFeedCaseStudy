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
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                completion(.failure(.connectivity))
            case .success(let data, let response):
                completion(self.map(data, from: response))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        if let feedItems = try? FeedItemsMapper.map(data, response) {
            return .success(feedItems)
        } else {
            return .failure(.invalidData)
        }
    }
}
