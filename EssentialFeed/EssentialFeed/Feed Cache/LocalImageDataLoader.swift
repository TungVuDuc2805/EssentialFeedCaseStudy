//
//  LocalImageDataLoader.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 03/10/2023.
//

import Foundation

public protocol ImageDataStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteImageData(with url: URL, completion: @escaping DeletionCompletion)
    func insert(_ image: Data, with url: URL, completion: @escaping InsertionCompletion)
    func retrieve(from url: URL)
}

public final class LocalImageDataLoader {
    private let store: ImageDataStore
    
    public init(store: ImageDataStore) {
        self.store = store
    }
    
    public func save(_ imageData: Data, with url: URL, completion: @escaping (Error?) -> Void) {
        store.deleteImageData(with: url) { [weak self] deletionError in
            guard let self = self else { return }
            guard deletionError == nil else {
                return completion(deletionError)
            }
            store.insert(imageData, with: url) { [weak self] insertionError in
                guard self != nil else { return }
                completion(insertionError)
            }
        }
    }
    
    public func loadImageData(from url: URL) {
        store.retrieve(from: url)
    }
}
