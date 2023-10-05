//
//  ImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 03/10/2023.
//

import Foundation
import EssentialFeed

class ImageDataStoreSpy: ImageDataStore {
    enum Message: Equatable {
        case deletion(URL)
        case insertion(Data, URL)
        case retrieval(URL)
    }
    var messages = [Message]()
    
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()
    var retrievalCompletions = [RetrievalCompletion]()

    func deleteImageData(with url: URL, completion: @escaping DeletionCompletion) {
        messages.append(.deletion(url))
        deletionCompletions.append(completion)
    }
    
    func completeDeletionWith(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ image: Data, with url: URL, completion: @escaping InsertionCompletion) {
        messages.append(.insertion(image, url))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func retrieve(from url: URL, completion: @escaping RetrievalCompletion) {
        messages.append(.retrieval(url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrievalWith(_ error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalSuccessfully(with data: Data, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
}
