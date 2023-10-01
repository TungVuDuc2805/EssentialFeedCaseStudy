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

class FeedImagePresenter<Image, View: FeedImageView> where View.Image == Image {
    private let view: View
    private let transformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.transformer = imageTransformer
    }

    private struct InvalidImageDataError: Error {}

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

    func didEndLoadingImage(with imageData: Data, model: FeedImage) {
        guard let image = transformer(imageData) else {
            return didEndLoadingImage(with: InvalidImageDataError(), model: model)
        }
        view.display(FeedImageViewModel(descriptionText: model.description, locationText: model.location, isLoading: false, imageData: image))
    }
}

class FeedImagePresenterTets: XCTestCase {
    
    func test_didStartLoadingImage_sendPresentableModelWithoutImageToView() {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter<String, ViewSpy>(view: viewSpy, imageTransformer: { data in return String(data: data, encoding: .utf8)})
        let model = uniqueFeedImage()
        
        sut.didStartLoadingImage(model)
        
        XCTAssertEqual(viewSpy.messages[0], .init(descriptionText: model.description, locationText: model.location, isLoading: true, imageData: nil))
    }
    
    func test_didEndLoadingImageWithError_sendPresentableModelWithoutImageToView() {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter<String, ViewSpy>(view: viewSpy, imageTransformer: { data in return String(data: data, encoding: .utf8)})
        let model = uniqueFeedImage()
        
        sut.didEndLoadingImage(with: anyNSError(), model: model)
        
        XCTAssertEqual(viewSpy.messages[0], .init(descriptionText: model.description, locationText: model.location, isLoading: false, imageData: nil))
    }
    
    func test_didEndLoadingImageWithInvalidData_sendPresentableModelWithoutImageToView() {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter<String, ViewSpy>(view: viewSpy, imageTransformer: { _ in return nil })
        let model = uniqueFeedImage()
        let data = Data("invalid data".utf8)
        sut.didEndLoadingImage(with: data, model: model)
        
        XCTAssertEqual(viewSpy.messages[0], .init(descriptionText: model.description, locationText: model.location, isLoading: false, imageData: nil))
    }
    
    func test_didEndLoadingImageWithImageData_sendPresentableModelWithoutImageToView() {
        let viewSpy = ViewSpy()
        let sut = FeedImagePresenter<String, ViewSpy>(view: viewSpy, imageTransformer: { data in return String(data: data, encoding: .utf8) })
        let model = uniqueFeedImage()
        let data = Data("any image data".utf8)
        sut.didEndLoadingImage(with: data, model: model)
        
        XCTAssertEqual(viewSpy.messages[0], .init(descriptionText: model.description, locationText: model.location, isLoading: false, imageData: "any image data"))
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
