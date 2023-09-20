//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    enum Error: Swift.Error {
        case unexpected
    }
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let res = response as? HTTPURLResponse, res.statusCode == 200, let data = data {
                completion(.success(data, res))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(Error.unexpected))
            }
        }
        .resume()
    }
    
}
