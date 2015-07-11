//
//  ViewController.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-10.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Cocoa
import AppKit
import WebKit
import CoreLocation

class ViewController: NSViewController, CLLocationManagerDelegate {

  var locationManager = CLLocationManager()
  @IBOutlet weak var webView: WebView!
  
  let mappy = Mappy(webView)
  
  private let CIRCLE_RECT_SIZE = 20.0
  
  func locationManager(manager: CLLocationManager,
                       didUpdateLocations locations: [AnyObject]) {
    if locations.first != nil, let location = locations.first! as? CLLocation {
      mappy.updateLocation(location.coordinate)
    }
  }
  
  func mask() {
    var blurView = NSVisualEffectView(frame: view.bounds)
    blurView.material = .Dark
    blurView.blendingMode = .BehindWindow
    blurView.state = .Active
    blurView.frame = view.frame
    
    view.addSubview(blurView, positioned: .Above, relativeTo: view)
    
    var maskLayer = CAShapeLayer()
    
    var maskPath = CGPathCreateMutable()
    CGPathAddRect(maskPath, nil, blurView.bounds)
    let w = Double(blurView.bounds.width)
    let h = Double(blurView.bounds.height)
    let x = (w - CIRCLE_RECT_SIZE) / 2
    let y = (h - CIRCLE_RECT_SIZE) / 2
    let rect = CGRect(x: x, y: y, width: CIRCLE_RECT_SIZE, height: CIRCLE_RECT_SIZE)
    CGPathAddEllipseInRect(maskPath, nil, rect)
    
    //    maskLayer.frame = view.bounds
    //    maskLayer.path = maskPath
    maskLayer.fillRule = "even-odd"
    
    println(maskLayer.position)
    
    blurView.layer!.mask = maskLayer
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
//    mappy.loadMap(CLLocationCoordinate2D(latitude: 59.335004, longitude: 18.126813999999968))
    locationManager.delegate = self
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
    
    mask()
  }

  override var representedObject: AnyObject? {
    didSet {
    // Update the view, if already loaded.
    }
  }

}

