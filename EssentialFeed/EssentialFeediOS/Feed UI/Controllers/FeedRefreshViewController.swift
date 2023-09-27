//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 27/09/2023.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    private let loader: FeedLoader
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        loader.load { [weak self] result in
            switch result {
            case .success(let images):
                self?.onRefresh?(images)
            case .failure:
                break
            }
            self?.view.endRefreshing()
        }
    }
}
