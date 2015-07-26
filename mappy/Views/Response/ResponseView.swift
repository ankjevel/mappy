//
//  ResponseView.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-25.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Cocoa

class ResponseView: NSView {
  
  var view: NSView!
  
  @IBOutlet weak var label: NSTextField!
  @IBOutlet weak var imageView: NSImageView!
  
  var content: ResponseElement! {
    didSet(content) {
      self.prepareView()
    }
  }
  
  override func drawRect(dirtyRect: NSRect) {
    super.drawRect(dirtyRect)
  }
  
  override var wantsUpdateLayer: Bool {
    return true
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    if let frame = NSScreen.mainScreen()?.frame {
      self.frame = frame
      NSBundle.mainBundle().loadNibNamed("Response", owner: self, topLevelObjects: nil)
      self.view.frame = frame
      self.addSubview(self.view!)
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}


private extension ResponseView {
  
  func prepareView() {
    let image = NSImage(contentsOfURL: content.images.thumbnail.url)
    imageView.image = image
    
    let caption = content.caption
    label.stringValue = caption
  }
  
}