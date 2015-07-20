//
//  ViewController.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-10.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Cocoa
import AppKit
import CoreLocation


class ViewController: NSViewController, CLLocationManagerDelegate {
  
  private let CIRCLE_RECT_SIZE = 20.0 as Double
  private let MINIMUM_DISTANCE_IN_METERS = 10.0
  
  private let locationManager = CLLocationManager()
  
  var mappy: Mappy?

  @IBOutlet weak var sharedView: NSView!
  @IBOutlet weak var mapView: NSView!
  @IBOutlet weak var mapLocationImageView: NSImageView!
  @IBOutlet weak var blurView: NSVisualEffectView!
  
  @IBAction func resetToHome(sender: AnyObject) {
    mappy!.resetToHome()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
    if locations.first != nil, let location = locations.first! as? CLLocation {
      mappy!.updateLocation(location.coordinate)
    }
  }
  
  func ondrag() {
    blurView.updateLayer()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // for some reason, lazy did not work
    self.mappy = Mappy(mapUpdated)
    
    let newMapView = mappy!.setView(view.frame)
    
    newMapView.frame = mapView.frame
    
    sharedView.replaceSubview(mapView, with: newMapView)
    mapView = newMapView
    
    mapView.layer?.zPosition = 0
    
    blurView.layer?.setNeedsLayout()
    blurView.alphaValue = 0.95
    
    setConstraints(&mapView!)
    
    locationManager.delegate = self
    locationManager.distanceFilter = MINIMUM_DISTANCE_IN_METERS
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }

  override func viewDidLayout() {
    mask()
  }
}

private extension ViewController {
  
  func mapUpdated(zoom: Bool) {
    if zoom {
      mask()
    } else {
      blurView.updateLayer()
    }
  }
  
  func setConstraints(inout view: NSView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: sharedView, attribute: .Top, multiplier: 1, constant: 0))
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Right, relatedBy: .Equal, toItem: sharedView, attribute: .Right, multiplier: 1, constant: 0))
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: sharedView, attribute: .Bottom, multiplier: 1, constant: 0))
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: sharedView, attribute: .Left, multiplier: 1, constant: 0))
  }
  
  func mask() {
    var maskLayer = CAShapeLayer()
    var maskPath = CGPathCreateMutable()
    
    let toolBarHeight: CGFloat = 21.0
    var height = view.frame.height - toolBarHeight
    CGPathAddRect(maskPath, nil, CGRectMake(0, 0, view.frame.width, height))
    
    maskLayer.fillRule = "even-odd"
    
    // TODO: Calculate radius of cutout
    let radius = CGFloat(Double(mappy!.zoom) * Double(mappy!.zoom))
    
    let x = CGFloat(Double(view.frame.width / 2) - Double(radius / 2))
    let y = CGFloat(Double(height / 2) - Double(radius / 2))
  
    CGPathAddRoundedRect(maskPath, nil, CGRectMake(x, y, radius, radius), CGFloat(radius / 2), CGFloat(radius / 2))
    
    maskLayer.path = maskPath

    if let blurLayer = blurView.layer {
      blurLayer.mask = maskLayer
      blurLayer.zPosition = 1
      mapLocationImageView.layer?.zPosition = 2
      blurView.updateLayer()
    }
  }

}