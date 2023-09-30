//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 26/09/2023.
//

import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView {
    var feed = [FeedImageCellController]()
    var loadFeed: (() -> Void)?

    private var onViewIsAppearing: ((FeedViewController) -> Void)?

    public override func viewDidLoad() {
        super.viewDidLoad()
                
        onViewIsAppearing = { [weak self] vc in
            vc.onViewIsAppearing = nil
            self?.refresh()
        }
    }
    
    func display(_ model: FeedLoadingViewModel) {
        if model.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func refresh() {
        loadFeed?()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(at: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cellController(at: indexPath).loadImage()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cancelCellControllerLoad(at: $0) }
    }
    
    private func cancelCellControllerLoad(at indexPath: IndexPath) {
        feed[indexPath.row].cancelLoad()
    }
    
    private func cellController(at indexPath: IndexPath) -> FeedImageCellController {
        return feed[indexPath.row]
    }
}
