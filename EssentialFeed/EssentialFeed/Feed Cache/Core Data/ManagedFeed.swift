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
