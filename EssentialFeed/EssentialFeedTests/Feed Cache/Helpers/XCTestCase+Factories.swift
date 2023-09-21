//
//  XCTestCase+Helpers.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import XCTest
import EssentialFeed

extension XCTestCase {
    func anyNSError() -> NSError {
        NSError(domain: "test", code: 0)
    }
    
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
}
