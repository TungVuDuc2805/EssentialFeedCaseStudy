//
//  UIImage+Helpers.swift
//  EssentialFeediOSTests
//
//  Created by Tung Vu Duc on 30/09/2023.
//

import UIKit

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
