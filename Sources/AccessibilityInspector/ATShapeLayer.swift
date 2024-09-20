//
//  ATShapeLayer.swift
//  GroupMe
//
//  Created by Divya on 11/10/23.
//  Copyright © 2023 Microsoft. All rights reserved.
//

    import Foundation
    import UIKit

    class ATShapeLayer: CAShapeLayer {
        init(size: CGSize, colour: UIColor) {
            super.init()
            let buffer: CGFloat = UIAccessibility.isReduceMotionEnabled ? 5 : 0
            frame = CGRect(x: -buffer, y: -buffer, width: size.width + 2 * buffer, height: size.height + 2 * buffer)
            borderColor = colour.cgColor
            borderWidth = 2
            cornerRadius = 5
            self.startAnimating()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        func startAnimating() {
            if !UIAccessibility.isReduceMotionEnabled {
                self.animateToScale(scaleVal: 1.05)
            }
        }

        func animateToScale(scaleVal: CGFloat) {
            let scale = CABasicAnimation(keyPath: "transform")
            scale.duration = 0.1
            var tr = CATransform3DIdentity
            tr = CATransform3DScale(tr, scaleVal, scaleVal, 1)
            scale.toValue = NSValue(caTransform3D: tr)
            scale.isRemovedOnCompletion = false
            scale.repeatCount = 2
            scale.autoreverses = true
            add(scale, forKey: "animate")
        }
    }
