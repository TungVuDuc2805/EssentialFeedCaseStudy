//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
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
    
    func performAsync(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let managedContext = managedContext
        managedContext.perform {
            action(managedContext)
        }
    }
}
