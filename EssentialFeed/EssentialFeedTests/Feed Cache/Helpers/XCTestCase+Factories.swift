//
//  XCTestCase+Helpers.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import XCTest
import EssentialFeed

extension XCTestCase {
    func uniqueFeedImage(
        id: UUID = UUID(),
        description: String? = "any description",
        location: String? = "any location",
        image: URL = URL(string: "any-url")!
    ) -> FeedImage {
        return FeedImage(id: id, description: description, location: location, url: image)
    }
    
    func uniqueItems(_ models: [FeedImage]) -> (models: [FeedImage], locals: [LocalFeedImage]) {
        let locals = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }

        return (models, locals)
    }
    
    func anyUniqueItems() -> (models: [FeedImage], locals: [LocalFeedImage]) {
        return uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
    }
}

extension Date {
    private var expirationDate: Int {
        return 7
    }
    
    func toExpirationDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: .day, value: -expirationDate, to: self)!
    }
    
    func adding(second: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: .second, value: second, to: self)!
    }
}
