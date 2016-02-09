//
//  AppDelegate.swift
//  API Endpoint Diff Checker
//
//  Created by Andrew Gerst on 2/8/16.
//  Copyright © 2016 Andrew Gerst. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let myViewController = MyViewController()
    let mySecondViewController = MySecondViewController()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application

        self.window.backgroundColor = NSColor.redColor()

        showMyViewController()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func showMyViewController() {
        self.window.contentView = myViewController.view
    }

    func showMySecondViewController() {
        self.window.contentView = mySecondViewController.view
    }

}
