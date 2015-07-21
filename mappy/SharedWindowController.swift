//
//  SharedWindowController.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-21.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Cocoa

class SharedWindowController: NSWindowController {
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    window?.contentViewController = MapHolderViewController(nibName: "MapHolder", bundle: NSBundle())
  }
    
}
