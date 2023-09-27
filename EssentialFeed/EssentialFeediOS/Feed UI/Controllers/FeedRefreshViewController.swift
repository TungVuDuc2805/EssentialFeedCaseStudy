//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 27/09/2023.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    lazy var view = binded(UIRefreshControl())
    private let viewModel: FeedRefreshViewModel
    
    init(viewModel: FeedRefreshViewModel) {
        self.viewModel = viewModel
    }
        
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        viewModel.onFeedLoadingState = { isLoading in
            if isLoading {
                view.beginRefreshing()
            } else {
                view.endRefreshing()
            }
        }

        return view
    }
    
    @objc func refresh() {
        viewModel.load()
    }
}
