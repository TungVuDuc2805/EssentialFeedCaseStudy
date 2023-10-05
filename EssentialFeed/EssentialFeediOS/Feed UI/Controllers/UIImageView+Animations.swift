//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by Tung Vu Duc on 30/09/2023.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        if newImage != nil {
            alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 1
            })
        }
    }
}
