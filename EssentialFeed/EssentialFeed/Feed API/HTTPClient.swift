//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 14/09/2023.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
