//
//  RemoteImageDataLoader.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import Foundation

public final class RemoteImageDataLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case clientError
        case invalidData
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    private class Task: Cancellable {
        var completion: ((Result<Data, Swift.Error>) -> Void)?
        
        init(completion: @escaping (Result<Data, Swift.Error>) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            completion = nil
        }
        
        func handle(_ result: Result<(Data, HTTPURLResponse), Swift.Error>) {
            switch result {
            case .success(let (data, response)):
                guard response.statusCode == 200 else {
                    completion?(.failure(Error.invalidData))
                    return
                }
                completion?(.success(data))
            case .failure:
                completion?(.failure(Error.clientError))
            }
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void) -> Cancellable {
        let task = Task(completion: completion)
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            task.handle(result)
        }
        
        return task
    }

}
