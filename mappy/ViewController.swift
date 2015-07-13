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

  @IBOutlet weak var sharedView: NSView!
  @IBOutlet weak var mapView: NSView!
  @IBOutlet weak var mapLocationImageView: NSImageView!
  
  @IBAction func resetToHome(sender: AnyObject) {
    mappy.resetToHome()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
    if locations.first != nil, let location = locations.first! as? CLLocation {
      mappy.updateLocation(location.coordinate)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let newMapView = mappy.setView(view.frame) as WKWebView
    newMapView.frame = mapView.frame
    
    sharedView.replaceSubview(mapView, with: newMapView)
    mapView = newMapView
    
    self.view.window?.title = "Mappy"
    mapView.layer?.zPosition = 0
    mapLocationImageView.layer?.zPosition = 1
    
    setConstraints(&mapView!)
    
    locationManager.delegate = self
    locationManager.distanceFilter = MINIMUM_DISTANCE_IN_METERS // distance in meters
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
    
//    mask()
  }
}

private extension ViewController {
  
  func setConstraints(inout view: NSView) {
    
    view.translatesAutoresizingMaskIntoConstraints = false
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: sharedView, attribute: .Top, multiplier: 1, constant: 0))
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Right, relatedBy: .Equal, toItem: sharedView, attribute: .Right, multiplier: 1, constant: 0))
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: sharedView, attribute: .Bottom, multiplier: 1, constant: 0))
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: sharedView, attribute: .Left, multiplier: 1, constant: 0))
  }
  
  func mask() {
    var blurView = NSVisualEffectView(frame: view.bounds)
    blurView.material = .Dark
    blurView.blendingMode = .BehindWindow
    blurView.state = .Active
    blurView.frame = view.frame
    
    view.addSubview(blurView, positioned: .Above, relativeTo: view)
    
//    var maskLayer = CAShapeLayer()
//    var maskPath = CGPathCreateMutable()
//    CGPathAddRect(maskPath, nil, blurView.bounds)
//    let w = Double(blurView.bounds.width)
//    let h = Double(blurView.bounds.height)
//    let x = (w - CIRCLE_RECT_SIZE) / 2
//    let y = (h - CIRCLE_RECT_SIZE) / 2
//    let rect = CGRect(x: x, y: y, width: CIRCLE_RECT_SIZE, height: CIRCLE_RECT_SIZE)
//    CGPathAddEllipseInRect(maskPath, nil, rect)
//    
//    maskLayer.frame = view.bounds
//    maskLayer.path = maskPath
//    maskLayer.fillRule = "even-odd"
//    
//    blurView.layer!.mask = maskLayer
  }

}