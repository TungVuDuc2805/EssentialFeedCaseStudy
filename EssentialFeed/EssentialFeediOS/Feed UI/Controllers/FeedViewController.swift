//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 26/09/2023.
//

import Foundation
import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: FeedRefreshViewController?
    private var imageLoader: ImageLoader?
    private var feed = [FeedImage]()
    private var cellControllers = [IndexPath: FeedImageCellController]()
    
    public convenience init(loader: FeedLoader, imageLoader: ImageLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController(loader: loader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController?.view
        tableView.prefetchDataSource = self
        refreshController?.refresh()
        
        refreshController?.onRefresh = { [weak self] in
            self?.feed = $0
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(at: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCell(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let controller = cellController(at: indexPath)
            _ = controller.view()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { removeCell(at: $0) }
    }
    
    private func removeCell(at indexPath: IndexPath) {
        cellControllers[indexPath]?.cancelLoad()
        cellControllers[indexPath] = nil
    }
    
    private func cellController(at indexPath: IndexPath) -> FeedImageCellController {
        let image = feed[indexPath.row]
        let controller = FeedImageCellController(model: image, imageLoader: imageLoader!)
        cellControllers[indexPath] = controller

        return controller
    }
}
