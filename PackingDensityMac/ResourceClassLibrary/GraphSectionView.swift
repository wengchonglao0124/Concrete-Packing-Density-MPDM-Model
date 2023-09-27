//
//  GraphSectionView.swift
//  PackingDensityMac
//
//  Created by weng chong lao on 09/04/2023.
//

import Cocoa

class GraphSectionView: NSView {
    var onClick: (() -> Void)?

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        onClick?()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(calibratedRed: 38/255, green: 40/255, blue: 41/255, alpha: 0.9).cgColor
    }
}
