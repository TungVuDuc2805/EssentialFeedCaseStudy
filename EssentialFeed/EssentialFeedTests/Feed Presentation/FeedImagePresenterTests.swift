//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import XCTest
import EssentialFeed

struct FeedImageViewModel<Image> {
    let descriptionText: String?
    let locationText: String?
    let isLoading: Bool
    let imageData: Image?
    
    var isLocationHidden: Bool {
        locationText == nil
    }
    
    var isRetryButtonHidden: Bool {
        imageData != nil || isLoading
    }
}

protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}

class FeedImagePresenter<Image, View: FeedImageView> {
    private let view: View
    
    init(view: View) {
        self.view = view
    }
    
    func didStartLoadingImage(_ model: FeedImage) {
        view.display(FeedImageViewModel(
            descriptionText: model.description,
            locationText: model.location,
            isLoading: true,
            imageData: nil)
        )
    }
    
    func didEndLoadingImage(with error: Error, model: FeedImage) {
        view.display(FeedImageViewModel(
            descriptionText: model.description,
            locationText: model.location,
            isLoading: false,
            imageData: nil)
        )
    }

}

class FeedImagePresenterTets: XCTestCase {
    
    func test_didStartLoadingImage_sendPresentableModelWithoutImageToView() {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter<String, ViewSpy>(view: viewSpy)
        let model = uniqueFeedImage()
        
        sut.didStartLoadingImage(model)
        
        XCTAssertEqual(viewSpy.messages[0], .init(descriptionText: model.description, locationText: model.location, isLoading: true, imageData: nil))
    }
    
    func test_didEndLoadingImageWithError_sendPresentableModelWithoutImageToView() {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter<String, ViewSpy>(view: viewSpy)
        let model = uniqueFeedImage()
        
        sut.didEndLoadingImage(with: anyNSError(), model: model)
        
        XCTAssertEqual(viewSpy.messages[0], .init(descriptionText: model.description, locationText: model.location, isLoading: false, imageData: nil))
    }
    
    // MARK : - Helpers
    private class ViewSpy: FeedImageView {
        var messages = [FeedImageViewModel<String>]()
        
        func display(_ model: FeedImageViewModel<String>) {
            self.messages.append(model)
        }
        
    }
    
}

extension FeedImageViewModel: Equatable where Image: Equatable {}
