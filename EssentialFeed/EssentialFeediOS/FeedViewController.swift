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

public final class FeedViewController: UITableViewController {
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
        tasks[indexPath] = imageLoader?.loadImageData(from: image.url) { result in
            let data = try? result.get()
            cell.feedImageView.image = data.map(UIImage.init) ?? nil
            cell.retryButton.isHidden = data != nil
            cell.contentContainer.isShimmering = false
        }
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
    }
    
}
