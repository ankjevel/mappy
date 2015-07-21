//
//  MapController.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-10.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Cocoa
import AppKit
import CoreLocation

/// Map related Views
class MapController: NSViewController, CLLocationManagerDelegate {
  
  /// How sensitive `CLLocationManager` will be
  private let MINIMUM_DISTANCE_IN_METERS = 10.0
  /// Zoom radius based on "feelings"
  private let ZOOM_RADIUS = [1, 1, 1, 1, 1, 2, 5, 10, 20, 50, 100, 180, 250, 450, 500, 550, 600, 800, 1000, 1500, 2500, 4000]
  
  private let locationManager = CLLocationManager()
  private let mappy = Mappy()

  /// Container for map-related `NSView` and elements
  @IBOutlet weak var sharedView: NSView!
  /// Google maps-view
  @IBOutlet weak var mapView: NSView!
  /// Icon for centering view on current location
  @IBOutlet weak var mapLocationImageView: NSImageView!
  /// Effect layer for "blur" over map
  @IBOutlet weak var blurView: NSVisualEffectView!
  
  /**
  Click-event for when the user clicks on the
  "current location" button on the UI
  */
  @IBAction func resetToHome(sender: AnyObject) {
    mappy.resetToHome()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
    if locations.first != nil, let location = locations.first! as? CLLocation {
      mappy.updateLocation(location.coordinate)
    }
  }
  
  /// Initialize the view
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mappy.addActionOnUpdate(mapUpdated)
    mappy.initView(view.frame)
    
    let newMapView = mappy.view
    
    newMapView.frame = mapView.frame
    
    sharedView.replaceSubview(mapView, with: newMapView)
    mapView = newMapView
    
    mapView.layer?.zPosition = 0
    blurView.layer?.setNeedsLayout()
    blurView.alphaValue = 0.80
    
    setConstraints(&mapView!)
    
    locationManager.delegate = self
    locationManager.distanceFilter = MINIMUM_DISTANCE_IN_METERS
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }

  /// When view is redrawn, update the map-mask as well
  override func viewDidLayout() {
    mask()
  }
}

private extension MapController {
  
  /**
  Evaluate if the mask over the map needs to update
  it's size or just redrawn
  
  :param: zoom:Bool
    true if the zoom has been updated
  */
  func mapUpdated(zoom: Bool) {
    if zoom {
      mask()
    } else {
      blurView.updateLayer()
    }
  }
  
  /**
  Add constraints to a view

  :param: view:NSView
    `NSView` used to add constraints to
  */
  func setConstraints(inout view: NSView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: sharedView, attribute: .Top, multiplier: 1, constant: 0))
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Right, relatedBy: .Equal, toItem: sharedView, attribute: .Right, multiplier: 1, constant: 0))
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: sharedView, attribute: .Bottom, multiplier: 1, constant: 0))
    sharedView.addConstraint(NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: sharedView, attribute: .Left, multiplier: 1, constant: 0))
    
  }
  
  /// Draws the mask over the map (into `blurView`)
  func mask() {
    var maskLayer = CAShapeLayer()
    var maskPath = CGPathCreateMutable()
    
    let toolBarHeight: CGFloat = 21.0
    var height = view.frame.height - toolBarHeight
    CGPathAddRect(maskPath, nil, CGRectMake(0, 0, view.frame.width, height))
    
    maskLayer.fillRule = "even-odd"
    
    let radius = CGFloat(ZOOM_RADIUS[mappy.zoom])
    let x = CGFloat(Double(view.frame.width / 2) - Double(radius / 2))
    let y = CGFloat(Double(height / 2) - Double(radius / 2))
  
    CGPathAddRoundedRect(maskPath, nil, CGRectMake(x, y, radius, radius), CGFloat(radius / 2), CGFloat(radius / 2))
    
    maskLayer.path = maskPath


    if let blurLayer = blurView.layer {
      blurLayer.mask = maskLayer
      blurLayer.zPosition = 1
      mapLocationImageView.layer?.zPosition = 2
      println("\(mappy.zoom), \(radius)")
      blurView.updateLayer()
    }
  }

}