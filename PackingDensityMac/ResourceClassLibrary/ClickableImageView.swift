//
//  ClickableImageView.swift
//  PackingDensityMac
//
//  Created by weng chong lao on 06/04/2023.
//

import Cocoa

class ClickableImageView: NSImageView {
    var onClick: (() -> Void)?

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        onClick?()
    }
}

