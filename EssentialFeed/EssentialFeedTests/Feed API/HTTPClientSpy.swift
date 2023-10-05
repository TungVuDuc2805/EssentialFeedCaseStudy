//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import Foundation
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func completeWithError(at index: Int = 0) {
        let error = NSError(domain: "test", code: 0)
        messages[index].completion(.failure(error))
    }
    
    func completeWith(data: Data = Data(), statusCode code: Int = 200, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success((data, response)))
    }
}
