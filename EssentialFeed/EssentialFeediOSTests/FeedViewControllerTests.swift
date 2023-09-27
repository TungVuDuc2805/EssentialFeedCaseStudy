//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Tung Vu Duc on 26/09/2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedAction_requestsFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(loader.loadFeedCallCount, 2)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(loader.loadFeedCallCount, 3)
    }
    
    func test_loadingIndicator_hidesOnLoadingCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isFeedRefreshing, true)
        loader.completeFeedLoading()
        XCTAssertEqual(sut.isFeedRefreshing, false)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(sut.isFeedRefreshing, true)
        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isFeedRefreshing, false)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(sut.isFeedRefreshing, true)
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertEqual(sut.isFeedRefreshing, false)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: nil, location: nil)
        let image3 = makeImage(description: "another description", location: "another other location")

        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 0)
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assert(sut: sut, renders: [image0])
        
        sut.simulatePullToRefresh()
        loader.completeFeedLoading(with: [image1, image2, image3], at: 1)
        assert(sut: sut, renders: [image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        
        sut.simulatePullToRefresh()
        loader.completeFeedLoadingWithError(at: 1)
        assert(sut: sut, renders: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImages, [])
        
        sut.simulateCellVisible(at: 0)
        XCTAssertEqual(loader.loadedImages, [image0.url])
        
        sut.simulateCellVisible(at: 1)
        XCTAssertEqual(loader.loadedImages, [image0.url, image1.url])
    }
    
    func test_feedImageView_cancelImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelLoadedImages, [])
        
        sut.simulateCellNotVisible(at: 0)
        XCTAssertEqual(loader.loadedImages, [image0.url])
        
        sut.simulateCellNotVisible(at: 1)
        XCTAssertEqual(loader.loadedImages, [image0.url, image1.url])
    }
    
    func test_feedImageViewLoadingIndicator_visibleWhileLoadingImage() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        let view0 = sut.simulateCellVisible(at: 0)
        let view1 = sut.simulateCellVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)

        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)

        loader.completeImageLoading(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false)
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)

        let view0 = sut.simulateCellVisible(at: 0)
        let view1 = sut.simulateCellVisible(at: 1)
        
        XCTAssertEqual(view0?.renderedImage, .none)
        XCTAssertEqual(view1?.renderedImage, .none)

        let imageData0 = UIImage.makeImage(of: .red).pngData()!
        loader.completeImageLoading(imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0)
        XCTAssertEqual(view1?.renderedImage, .none)

        let imageData1 = UIImage.makeImage(of: .white).pngData()!
        loader.completeImageLoading(imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0)
        XCTAssertEqual(view1?.renderedImage, imageData1)
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)

        let view0 = sut.simulateCellVisible(at: 0)
        let view1 = sut.simulateCellVisible(at: 1)
        
        XCTAssertEqual(view0?.isRetryButtonVisible, false)
        XCTAssertEqual(view1?.isRetryButtonVisible, false)

        loader.completeImageLoadingWithError(at: 0)
        XCTAssertEqual(view0?.isRetryButtonVisible, true)
        XCTAssertEqual(view1?.isRetryButtonVisible, false)

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isRetryButtonVisible, true)
        XCTAssertEqual(view1?.isRetryButtonVisible, true)
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()], at: 0)

        let view0 = sut.simulateCellVisible(at: 0)
        
        XCTAssertEqual(view0?.isRetryButtonVisible, false)

        let invalidImageData = Data("invalid data".utf8)
        loader.completeImageLoading(invalidImageData, at: 0)
        XCTAssertEqual(view0?.isRetryButtonVisible, true)
    }
    
    func test_retryAction_reloadsImage() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        let view0 = sut.simulateCellVisible(at: 0)
        let view1 = sut.simulateCellVisible(at: 1)
        
        XCTAssertEqual(loader.loadedImages, [image0.url, image1.url])

        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)

        view0?.simulateRetry()
        XCTAssertEqual(loader.loadedImages, [image0.url, image1.url, image0.url])

        view1?.simulateRetry()
        XCTAssertEqual(loader.loadedImages, [image0.url, image1.url, image0.url, image1.url])
    }
    
    func test_feedImageView_loadsImageOnCellNearVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImages, [])

        sut.simulateNearCellVisible(at: 0)
        XCTAssertEqual(loader.loadedImages, [image0.url])

        sut.simulateNearCellVisible(at: 1)
        XCTAssertEqual(loader.loadedImages, [image0.url, image1.url])
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func assert(sut: FeedViewController, renders feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            XCTFail("Expect \(feed.count) cells but got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
            return
        }

        feed.enumerated().forEach { index, image in
            assert(sut: sut, configuresCellWithImage: image, at: index)
        }
    }
    
    private func assert(sut: FeedViewController, configuresCellWithImage image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let cell = sut.feedCell(at: index)
        XCTAssertNotNil(cell, "Expect FeedCell type but got \(type(of: cell)) instead")
        XCTAssertEqual(cell?.descriptionLabel.text, image.description, file: file, line: line)
        XCTAssertEqual(cell?.locationLabel.text, image.location, file: file, line: line)
        XCTAssertEqual(cell?.locationContainer.isHidden, image.location == nil, file: file, line: line)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "any-url")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
        
    class LoaderSpy: FeedLoader, ImageLoader {
        var loadFeedCallCount: Int {
            completions.count
        }
        
        private var completions = [(LoadFeedResult) -> Void]()
        
        func load(completion: @escaping (LoadFeedResult) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            completions[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            completions[index](.failure(NSError(domain: "test", code: 0)))
        }
        
        // MARK: - Image Load
        var loadedImages = [URL]()
        var cancelLoadedImages = [URL]()
        var imageLoadCompletions = [(Result<Data, Error>) -> Void]()
        
        struct Task: Cancellable {
            var handler: () -> Void
            func cancel() {
                handler()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
            loadedImages.append(url)
            imageLoadCompletions.append(completion)
            
            return Task {
                self.cancelLoadedImages.append(url  )
            }
        }
        
        func completeImageLoading(_ data: Data = Data(), at index: Int) {
            imageLoadCompletions[index](.success(data))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            imageLoadCompletions[index](.failure(NSError(domain: "test", code: 0)))
        }
    }
    
}

extension FeedViewController {
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
    
    func simulateNearCellVisible(at index: Int) {
        let pf = tableView.prefetchDataSource
        pf?.tableView(tableView, prefetchRowsAt: [IndexPath(row: index, section: 0)])
    }
    
    var feedImageSection: Int {
        return 0
    }
}

extension UIRefreshControl {
    func simulatePull() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

extension FeedCell {
    var isShowingImageLoadingIndicator: Bool {
        return contentContainer.isShimmering
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
    
    var isRetryButtonVisible: Bool {
        return !retryButton.isHidden
    }
    
    func simulateRetry() {
        retryButton.simulateTap()
    }
}

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

extension UIImage {
    static func makeImage(of color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
