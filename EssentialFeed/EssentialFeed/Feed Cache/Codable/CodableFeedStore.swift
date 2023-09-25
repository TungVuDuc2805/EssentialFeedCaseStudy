//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 22/09/2023.
//

import Foundation

public class CodableFeedStore: FeedStore {
    struct CodableCache: Codable {
        let items: [CodableLocalFeedImage]
        let timestamp: Date
        
        init(items: [LocalFeedImage], timestamp: Date) {
            self.items = items.map {
                CodableLocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
            }
            self.timestamp = timestamp
        }
        
        struct CodableLocalFeedImage: Codable {
            let id: UUID
            let description: String?
            let location: String?
            let url: URL
        }
    }
    
    private let url: URL
    private let queue = DispatchQueue(label: "com.feedstore.queue", attributes: .concurrent)
    
    public init(url: URL) {
        self.url = url
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        queue.async { [url] in
            guard let data = try? Data(contentsOf: url) else {
                completion(.empty)
                return
            }
            
            do {
                let cache = try JSONDecoder().decode(CodableCache.self, from: data)
                completion(.success(timestamp: cache.timestamp, locals: cache.items.map {
                    LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
                }))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ items: [LocalFeedImage], _ timestamp: Date, completion: @escaping InsertionCompletion) {
        queue.async(flags: .barrier) { [url] in
            let cache = CodableCache(items: items, timestamp: timestamp)
            let data = try! JSONEncoder().encode(cache)
            do {
                try data.write(to: url)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        queue.async(flags: .barrier) { [url] in
            guard FileManager.default.fileExists(atPath: url.path) else {
                completion(nil)
                return
            }
            do {
                try FileManager.default.removeItem(at: url)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
