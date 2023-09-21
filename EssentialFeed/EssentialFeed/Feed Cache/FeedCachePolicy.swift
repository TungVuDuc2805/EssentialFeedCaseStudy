//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 21/09/2023.
//

import Foundation

internal struct FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }

    static func validate(_ timestamp: Date, with currentDate: Date) -> Bool {
        guard let expirationDate = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        
        return expirationDate > currentDate
    }
}
