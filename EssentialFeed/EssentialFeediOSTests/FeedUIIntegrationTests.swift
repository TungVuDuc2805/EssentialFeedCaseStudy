//
//  FeedUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Tung Vu Duc on 26/09/2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, "My Feed")
    }
    
    func test_loadFeedAction_requestsFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0)

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(loader.loadFeedCallCount, 2)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(loader.loadFeedCallCount, 3)
    }
    
    func test_loadingIndicator_hidesOnLoadingCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
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

        sut.simulateAppearance()
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
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        
        sut.simulatePullToRefresh()
        loader.completeFeedLoadingWithError(at: 1)
        assert(sut: sut, renders: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
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
        
        sut.simulateAppearance()
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
        
        sut.simulateAppearance()
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
        
        sut.simulateAppearance()
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
        
        sut.simulateAppearance()
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
        
        sut.simulateAppearance()
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
        
        sut.simulateAppearance()
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
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImages, [])

        sut.simulateCellNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImages, [image0.url])

        sut.simulateCellNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImages, [image0.url, image1.url])
    }
    
    func test_feedImageView_cancelLoadsImageOnCellNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelLoadedImages, [])

        sut.simulateCellNotNearVisibleAnymore(at: 0)
        XCTAssertEqual(loader.cancelLoadedImages, [image0.url])

        sut.simulateCellNotNearVisibleAnymore(at: 1)
        XCTAssertEqual(loader.cancelLoadedImages, [image0.url, image1.url])
    }
    
    func test_feedImageCell_doesNotRenderLoadedImageOnCellNoVisible() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with: [makeImage()], at: 0)

        let view0 = sut.simulateCellNotVisible(at: 0)
        
        let imageData0 = UIImage.makeImage(of: .red).pngData()!
        loader.completeImageLoading(imageData0, at: 0)
        
        XCTAssertNil(view0?.renderedImage)
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        let exp = expectation(description: "wait for completion")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadFeedImageCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with: [makeImage()], at: 0)
        sut.simulateCellVisible(at: 0)
        
        let exp = expectation(description: "wait for completion")
        DispatchQueue.global().async {
            loader.completeImageLoading(UIImage.makeImage(of: .red).pngData()!, at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.composeUIWith(feedLoader: loader, imageLoader: loader)
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
        var imageLoadCompletions = [(Swift.Result<Data, Error>) -> Void]()
        
        struct Task: Cancellable {
            var handler: () -> Void
            func cancel() {
                handler()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
            loadedImages.append(url)
            imageLoadCompletions.append(completion)
            
            return Task { [weak self] in
                self?.cancelLoadedImages.append(url)
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
