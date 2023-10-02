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
            ManagedFeed.insert(timestamp, items, to: managedContext)
            
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
            do {
                let result = try ManagedFeed.find(in: managedContext)
                guard let cache = result else {
                    return completion(.empty)
                }
                
                let images = cache.feed.map { $0.toLocal }
                
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
