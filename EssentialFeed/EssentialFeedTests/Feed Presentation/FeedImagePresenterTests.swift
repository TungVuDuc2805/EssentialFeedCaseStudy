//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTets: XCTestCase {
    
    func test_didStartLoadingImage_sendPresentableModelWithoutImageToView() {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter<String, ViewSpy>(view: viewSpy, imageTransformer: { data in return String(data: data, encoding: .utf8)})
        let model = uniqueFeedImage()
        
        sut.didStartLoadingImage(model)
        
        let message = viewSpy.messages[0]
        XCTAssertEqual(message.descriptionText, model.description)
        XCTAssertEqual(message.locationText, model.location)
        XCTAssertEqual(message.isLoading, true)
        XCTAssertEqual(message.isRetryButtonHidden, true)
        XCTAssertEqual(message.imageData, nil)
    }
    
    func test_didEndLoadingImageWithError_sendPresentableModelWithoutImageToView() {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter<String, ViewSpy>(view: viewSpy, imageTransformer: { data in return String(data: data, encoding: .utf8)})
        let model = uniqueFeedImage()
        
        sut.didEndLoadingImage(with: anyNSError(), model: model)
        
        let message = viewSpy.messages[0]
        XCTAssertEqual(message.descriptionText, model.description)
        XCTAssertEqual(message.locationText, model.location)
        XCTAssertEqual(message.isLoading, false)
        XCTAssertEqual(message.isRetryButtonHidden, false)
        XCTAssertEqual(message.imageData, nil)
    }
    
    func test_didEndLoadingImageWithInvalidData_sendPresentableModelWithoutImageToView() {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter<String, ViewSpy>(view: viewSpy, imageTransformer: { _ in return nil })
        let model = uniqueFeedImage()
        let data = Data("invalid data".utf8)
        sut.didEndLoadingImage(with: data, model: model)
        
        let message = viewSpy.messages[0]
        XCTAssertEqual(message.descriptionText, model.description)
        XCTAssertEqual(message.locationText, model.location)
        XCTAssertEqual(message.isLoading, false)
        XCTAssertEqual(message.isRetryButtonHidden, false)
        XCTAssertEqual(message.imageData, nil)
    }
    
    func test_didEndLoadingImageWithImageData_sendPresentableModelWithoutImageToView() {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter<String, ViewSpy>(view: viewSpy, imageTransformer: { data in return String(data: data, encoding: .utf8) })
        let model = uniqueFeedImage()
        let data = Data("any image data".utf8)
        sut.didEndLoadingImage(with: data, model: model)
        
        let message = viewSpy.messages[0]
        XCTAssertEqual(message.descriptionText, model.description)
        XCTAssertEqual(message.locationText, model.location)
        XCTAssertEqual(message.isLoading, false)
        XCTAssertEqual(message.isRetryButtonHidden, true)
        XCTAssertEqual(message.imageData, "any image data")
    }
    
    // MARK : - Helpers
    private class ViewSpy: FeedImageView {
        var messages = [FeedImageViewModel<String>]()
        
        func display(_ model: FeedImageViewModel<String>) {
            self.messages.append(model)
        }
        
    }
    
}
