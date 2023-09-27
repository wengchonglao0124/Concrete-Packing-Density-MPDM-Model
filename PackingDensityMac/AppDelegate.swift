//
//  AppDelegate.swift
//  PackingDensityMac
//
//  Created by weng chong lao on 16/3/2023.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    var gameViewController: GameViewController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

