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
  
  // MARK: constants
  private let CIRCLE_RECT_SIZE = 20.0
  private let MINIMUM_DISTANCE_IN_METERS = 10.0
  
  private let mappy = Mappy()
  private let locationManager = CLLocationManager()

  @IBOutlet weak var mapView: NSView!
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
    if locations.first != nil, let location = locations.first! as? CLLocation {
      mappy.updateLocation(location.coordinate)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.view = mappy.setView(&mapView!)
    self.view.window?.title = "Mappy"
    
    locationManager.delegate = self
    locationManager.distanceFilter = MINIMUM_DISTANCE_IN_METERS // distance in meters
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
    
//    mask()
  }

  override var representedObject: AnyObject? {
    didSet {
    // Update the view, if already loaded.
    }
  }

}

private extension ViewController {
  
  func mask() {
    var blurView = NSVisualEffectView(frame: view.bounds)
    blurView.material = .Dark
    blurView.blendingMode = .BehindWindow
    blurView.state = .Active
    blurView.frame = view.frame
    
    view.addSubview(blurView, positioned: .Above, relativeTo: view)
    
    //    var maskLayer = CAShapeLayer()
    //
    //    var maskPath = CGPathCreateMutable()
    //    CGPathAddRect(maskPath, nil, blurView.bounds)
    //    let w = Double(blurView.bounds.width)
    //    let h = Double(blurView.bounds.height)
    //    let x = (w - CIRCLE_RECT_SIZE) / 2
    //    let y = (h - CIRCLE_RECT_SIZE) / 2
    //    let rect = CGRect(x: x, y: y, width: CIRCLE_RECT_SIZE, height: CIRCLE_RECT_SIZE)
    //    CGPathAddEllipseInRect(maskPath, nil, rect)
    //
    //    //    maskLayer.frame = view.bounds
    //    //    maskLayer.path = maskPath
    //    maskLayer.fillRule = "even-odd"
    //
    //    println(maskLayer.position)
    //    
    //    blurView.layer!.mask = maskLayer
  }

}