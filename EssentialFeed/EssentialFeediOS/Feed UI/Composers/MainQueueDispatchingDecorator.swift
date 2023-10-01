//
//  MainQueueDispatchingDecorator.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 30/09/2023.
//

import Foundation
import EssentialFeed

final class MainQueueDispatchingDecorator<T> {
    let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async {
                action()
            }
        }
    }
}

extension MainQueueDispatchingDecorator: FeedLoader where T == FeedLoader {
    
    func load(completion: @escaping (FeedLoader.LoadFeedResult) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}


extension MainQueueDispatchingDecorator: ImageLoader where T == ImageLoader {
    
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        return decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
