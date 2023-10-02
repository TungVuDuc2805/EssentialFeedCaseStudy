//
//  ManagedImage+CoreDataProperties.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 01/10/2023.
//
//

import Foundation
import CoreData

@objc(ManagedImage)
public class ManagedImage: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var imageDescription: String?
    @NSManaged public var location: String?
    @NSManaged public var url: URL
    @NSManaged public var data: Data?
    @NSManaged public var feed: ManagedFeed
}

extension ManagedImage {
    var toLocal: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedImage? {
        let request = NSFetchRequest<ManagedImage>(entityName: ManagedImage.className())
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedImage.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
