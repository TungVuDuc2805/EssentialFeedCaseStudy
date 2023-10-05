//
//  MangedFeed+CoreDataProperties.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 01/10/2023.
//
//

import Foundation
import CoreData

@objc(ManagedFeed)
public class ManagedFeed: NSManagedObject {
    @NSManaged public var timestamp: Date
    @NSManaged public var cache: NSOrderedSet
}

extension ManagedFeed {
    static func uniqueInstance(in context: NSManagedObjectContext) throws -> ManagedFeed {
        try ManagedFeed.find(in: context).map(context.delete)
        
        return ManagedFeed(context: context)
    }
    
    func insert(_ timestamp: Date, _ locals: [LocalFeedImage], to context: NSManagedObjectContext) {
        self.timestamp = timestamp
        self.cache = NSOrderedSet(array: locals.map {
            let cacheItem = ManagedImage(context: context)
            cacheItem.id = $0.id
            cacheItem.imageDescription = $0.description
            cacheItem.location = $0.location
            cacheItem.url = $0.url
            
            return cacheItem
        })
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedFeed? {
        let request = NSFetchRequest<ManagedFeed>(entityName: ManagedFeed.entity().name!)
        request.returnsObjectsAsFaults = false
        let result = try context.fetch(request)
        guard let cache = result.first else {
            return nil
        }
        
        return cache
    }
    
    var feed: [ManagedImage] {
        cache.compactMap { $0 as? ManagedImage }
    }
}
