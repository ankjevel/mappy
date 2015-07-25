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
//    let imageContent = content.images.thumbnail
//    let image = NSImage(contentsOfURL: imageContent.url)
//    
//    let imageWidth = CGFloat(imageContent.width)
//    let imageHeight = CGFloat(imageContent.height)
//    
//    let frameWidth = view.frame.size.width
//    let scaleFactor: CGFloat = imageWidth / frameWidth
//    
//    let newHeight = imageHeight * scaleFactor
//    let newWidth = imageWidth * scaleFactor
//    //
//    //    UIGraphicsBeginImageContext();
//    //    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
//    //    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    //    UIGraphicsEndImageContext();
//    
//    println("old: [\(imageContent.width),\(imageContent.height)) new: [\(newWidth),\(newHeight))")
//    image?.size = NSMakeSize(newWidth, newHeight)
//    
//    let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: newWidth, height: newHeight))
//    
//    imageView.image = image
//    
//    view.addSubview(imageView)
  }
  
}