//
//  ControlSectionView.swift
//  PackingDensityMac
//
//  Created by weng chong lao on 05/04/2023.
//

import Cocoa

class ControlSectionView: NSView {
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
        layer?.backgroundColor = NSColor(calibratedRed: 38/255, green: 40/255, blue: 41/255, alpha: 0.5).cgColor
    }
}
