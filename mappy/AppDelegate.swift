//
//  AppDelegate.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-10.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSResponder, NSApplicationDelegate {

  var window: NSWindow?
  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }
  
  // If last window is closed, close application
  func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
    return true
  }
  
}







//  window = UIWindow(frame: UIScreen.mainScreen().bounds)
//  if let window = window {
//    window.backgroundColor = UIColor.whiteColor()
//    window.rootViewController = ViewController()
//    window.makeKeyAndVisible()
//  }