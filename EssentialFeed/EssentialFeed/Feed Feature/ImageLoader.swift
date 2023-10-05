//
//  ImageLoader.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 27/09/2023.
//

import Foundation

public protocol Cancellable {
    func cancel()
}

public protocol ImageLoader {
    typealias Result = (Swift.Result<Data, Error>) -> Void
    func loadImageData(from url: URL, completion: @escaping Result) -> Cancellable
}
