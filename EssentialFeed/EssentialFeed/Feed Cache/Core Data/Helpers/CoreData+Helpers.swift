//
//  CoreDataFeedStore+Helpers.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 02/10/2023.
//

import CoreData

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
