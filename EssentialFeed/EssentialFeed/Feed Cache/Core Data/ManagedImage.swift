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
    @NSManaged public var feed: MangedFeed
}
