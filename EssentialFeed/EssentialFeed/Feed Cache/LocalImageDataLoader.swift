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
    typealias RetrievalCompletion = (Result<Data, Error>) -> Void

    func deleteImageData(with url: URL, completion: @escaping DeletionCompletion)
    func insert(_ image: Data, with url: URL, completion: @escaping InsertionCompletion)
    func retrieve(from url: URL, completion: @escaping RetrievalCompletion)
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
    
    private class Task: Cancellable {
        var completion: ((Result<Data, Swift.Error>) -> Void)?
        
        init(completion: @escaping (Result<Data, Swift.Error>) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            completion = nil
        }
        
        func handle(_ result: Result<Data, Swift.Error>) {
            switch result {
            case .success(let data):
                completion?(.success(data))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        let task = Task(completion: completion)
        store.retrieve(from: url) { result in
            task.handle(result)
        }
        
        return task
    }
}
