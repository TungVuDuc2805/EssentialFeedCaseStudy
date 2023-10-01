//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    enum Error: Swift.Error {
        case invalidLoadManagedObject
    }
    
    private let persistentContainer: NSPersistentContainer
    private let managedContext: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        guard let model = NSManagedObjectModel.load(from: "FeedStore", in: Bundle(for: CoreDataFeedStore.self)) else {
            throw Error.invalidLoadManagedObject
        }
            
        do {
            persistentContainer = try NSPersistentContainer.load(from: "FeedStore", model: model, url: storeURL)
            managedContext = persistentContainer.newBackgroundContext()
        } catch {
            throw error
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ items: [LocalFeedImage], _ timestamp: Date, completion: @escaping InsertionCompletion) {
        let managedContext = managedContext
        managedContext.perform {
            let cache = MangedFeed(context: managedContext)
            cache.timestamp = timestamp
            cache.cache = NSOrderedSet(array: items.map {
                let cacheItem = ManagedImage(context: managedContext)
                cacheItem.id = $0.id
                cacheItem.imageDescription = $0.description
                cacheItem.location = $0.location
                cacheItem.url = $0.url
                
                return cacheItem
            })
            
            do {
                try managedContext.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let managedContext = managedContext
        managedContext.perform {
            let request = NSFetchRequest<MangedFeed>(entityName: MangedFeed.className())
            request.returnsObjectsAsFaults = false
            do {
                let result = try managedContext.fetch(request)
                guard let cache = result.first else {
                    return completion(.empty)
                }
                
                let images = cache.cache.compactMap { $0 as? ManagedImage }.map {
                    LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url)
                }
                
                completion(.success(timestamp: cache.timestamp, locals: images))
            } catch {
                completion(.failure(error))
            }
            
            try? managedContext.save()
        }
    }
    
}

extension NSManagedObjectModel {
    static func load(from name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap {
                NSManagedObjectModel(contentsOf: $0)
            }
    }
}

extension NSPersistentContainer {
    enum Error: Swift.Error {
        case invalidManagedObjectURL
        case failedToLoadContainer
    }

    static func load(from name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var capturedError: Swift.Error?
        container.loadPersistentStores { _, error in
            capturedError = error
        }
        if capturedError != nil {
            throw Error.failedToLoadContainer
        }
        
        return container
    }
}
