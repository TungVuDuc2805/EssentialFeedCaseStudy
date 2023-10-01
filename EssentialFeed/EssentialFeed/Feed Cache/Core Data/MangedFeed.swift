//
//  MangedFeed+CoreDataProperties.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 01/10/2023.
//
//

import Foundation
import CoreData

@objc(MangedFeed)
public class MangedFeed: NSManagedObject {
    @NSManaged public var timestamp: Date
    @NSManaged public var cache: NSOrderedSet
}
