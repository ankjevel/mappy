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
  
  /// Contains the shared window where Map is located
  let sharedWindow = SharedWindowController(windowNibName: "Shared")
  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
    sharedWindow.showWindow(nil)
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
    // If last window is closed, close application
    return true
  }
}