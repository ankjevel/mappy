//
//  Window.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-19.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Foundation
import AppKit
import Cocoa

class Window: NSWindowController {
  
  override init(window: NSWindow!) {
    super.init(window: window)
    println("aboo?", window.windowRef)
  }
  
  required init?(coder: (NSCoder!)) {
    super.init(coder: coder)
  }
  
  override func windowDidLoad() {
    super.windowDidLoad()
  }

}