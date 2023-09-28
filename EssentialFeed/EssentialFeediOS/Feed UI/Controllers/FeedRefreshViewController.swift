//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 27/09/2023.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    lazy var view = loadView()
    var presenter: FeedRefreshPresenter?
        
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    func display(_ isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    @objc func refresh() {
        presenter?.load()
    }
}
