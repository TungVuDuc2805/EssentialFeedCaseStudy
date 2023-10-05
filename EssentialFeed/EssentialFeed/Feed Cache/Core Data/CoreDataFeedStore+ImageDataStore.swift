//
//  CoreDataFeedStore+ImageDataStore.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 03/10/2023.
//

import CoreData

extension CoreDataFeedStore: ImageDataStore {
    public enum ImageDataStoreError: Swift.Error {
        case notFound
    }
    
    public func deleteImageData(with url: URL, completion: @escaping DeletionCompletion) {
        performAsync { context in
            do {
                let cache = try ManagedImage.first(with: url, in: context)
                cache?.data = nil
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ image: Data, with url: URL, completion: @escaping InsertionCompletion) {
        performAsync { context in
            do {
                let cache = try ManagedImage.first(with: url, in: context)
                cache?.data = image
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(from url: URL, completion: @escaping ImageDataStore.RetrievalCompletion) {
        performAsync { context in
            do {
                let cache = try ManagedImage.first(with: url, in: context)
                
                guard let data = cache?.data else {
                    return completion(.failure(ImageDataStoreError.notFound))
                }
                completion(.success(data))
                
                try context.save()
            } catch {
                completion(.failure(ImageDataStoreError.notFound))
            }
        }
    }
}
