//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 26/09/2023.
//

import Foundation
import UIKit
import EssentialFeed

public protocol Cancellable {
    func cancel()
}

public protocol ImageLoader {
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var loader: FeedLoader?
    private var imageLoader: ImageLoader?
    private var feed = [FeedImage]()
    private var tasks = [IndexPath: Cancellable]()
    
    public convenience init(loader: FeedLoader, imageLoader: ImageLoader) {
        self.init()
        self.loader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.prefetchDataSource = self
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            switch result {
            case .success(let images):
                self?.feed = images
            case .failure:
                break
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FeedCell()
        let image = feed[indexPath.row]
        cell.contentContainer.isShimmering = true
        cell.descriptionLabel.text = image.description
        cell.locationLabel.text = image.location
        cell.locationContainer.isHidden = image.location == nil
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        
        let imageLoad = { [weak self, weak cell] in
            guard let self = self else { return }
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: image.url) { result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.retryButton.isHidden = image != nil
                cell?.contentContainer.isShimmering = false
            }
        }
        
        imageLoad()
        
        cell.retry = imageLoad
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelImageLoad(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let image = feed[indexPath.row]
            tasks[indexPath] = imageLoader?.loadImageData(from: image.url) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cancelImageLoad(at: $0) }
    }
    
    private func cancelImageLoad(at indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
    }
}
