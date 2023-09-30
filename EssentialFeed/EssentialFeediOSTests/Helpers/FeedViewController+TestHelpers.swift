//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Tung Vu Duc on 30/09/2023.
//

import EssentialFeediOS
import UIKit

extension FeedViewController {
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithSpyForiOS17Support()
    }
    
    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }
    
    private func replaceRefreshControlWithSpyForiOS17Support() {
        let spyRefreshControl = UIRefreshControlSpy()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                spyRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = spyRefreshControl
    }
    
    private class UIRefreshControlSpy: UIRefreshControl {
        private var _isRefreshing = false
        
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
    
    func simulatePullToRefresh() {
        refreshControl?.simulatePull()
    }
    
    var isFeedRefreshing: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        let dataSource = tableView.dataSource
        return dataSource?.tableView(tableView, numberOfRowsInSection: feedImageSection) ?? 0
    }
    
    func feedCell(at index: Int) -> FeedCell? {
        let dataSource = tableView.dataSource
        let cell = dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: index, section: feedImageSection))
        return cell as? FeedCell
    }
    
    @discardableResult
    func simulateCellVisible(at index: Int) -> FeedCell? {
        return feedCell(at: index)
    }
    
    func simulateCellNotVisible(at index: Int) {
        let cell = simulateCellVisible(at: index)!
        let delegate = tableView.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: IndexPath(row: index, section: feedImageSection))
    }
    
    func simulateCellNearVisible(at index: Int) {
        let pf = tableView.prefetchDataSource
        pf?.tableView(tableView, prefetchRowsAt: [IndexPath(row: index, section: feedImageSection)])
    }
    
    func simulateCellNotNearVisibleAnymore(at index: Int) {
        simulateCellNearVisible(at: index)
        let pf = tableView.prefetchDataSource
        pf?.tableView?(tableView, cancelPrefetchingForRowsAt: [IndexPath(row: index, section: feedImageSection)])
    }
    
    var feedImageSection: Int {
        return 0
    }
}
