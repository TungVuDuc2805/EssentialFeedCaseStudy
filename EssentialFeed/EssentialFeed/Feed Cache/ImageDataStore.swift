//
//  ImageDataStore.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 03/10/2023.
//

import Foundation

public protocol ImageDataStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalResult = Result<Data, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    func deleteImageData(with url: URL, completion: @escaping DeletionCompletion)
    func insert(_ image: Data, with url: URL, completion: @escaping InsertionCompletion)
    func retrieve(from url: URL, completion: @escaping RetrievalCompletion)
}
