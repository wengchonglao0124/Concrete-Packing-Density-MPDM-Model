//
//  NSViewExtension.swift
//  PackingDensityMac
//
//  Created by weng chong lao on 09/04/2023.
//

import Cocoa

extension NSView {
    func rotate(byDegrees degrees: CGFloat) {
        let radians = CGFloat(degrees * Double.pi / 180)
        self.wantsLayer = true
        self.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.layer?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.layer?.transform = CATransform3DMakeRotation(radians, 0, 0, 1)
    }
}
