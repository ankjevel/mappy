//
//  MapHolderViewController.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-10.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Cocoa
import AppKit
import CoreLocation

/// Map related Views
class MapHolderViewController: NSViewController, CLLocationManagerDelegate {
  
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
  /*
  When locationManager get's updated, update
  `Mappy` location
  */
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
    if locations.first != nil, let location = locations.first! as? CLLocation {
      mappy.updateLocation(location.coordinate)
    }
  }
  
  // Initialize the view
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /*
    Add actions called when map-events
    gets called, like zoom and pan
    */
    mappy.addActionOnUpdate(mapUpdated)
    // Will set `Mappy.view`
    mappy.initView(view.frame)
    // Will replace previous map-view-placeholder
    let newMapView = mappy.view
    /*
    But just to be safe, copy previous frame from
    xib file
    */
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
  /*
  `viewDidLoad` is called before `viewDidAppear`
  and it's not required for window to be set in
  previous event
  */
  override func viewDidAppear() {
    super.viewDidAppear()
    
    view.window?.title = "mappy"
  }

  /// When view is redrawn, update the map-mask as well
  override func viewDidLayout() {
    if blurView != nil {
      mask()
    }
  }
}

private extension MapHolderViewController {
  
  /**
  Evaluate if the mask over the map needs to update
  it's size or just redrawn
  
  :param: zoom
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

  :param: view
    `NSView` used to add constraints to
  */
  func setConstraints(inout view: NSView) {
    // DO NOT FORGET THIS
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
    /**
    When using "Full Size Content View" on window,
    there is no toolbar but the toolbar buttons
    (if exists) still display.
    
    Unsure of how to calculate Toolbar height, so
    we just remove what we guess is the height
    */
    let toolbarHeight: CGFloat = 0 //21.0
    
    // Subtract toolbar height from frame height
    let height = view.frame.height - toolbarHeight
    
    // Add initial mask that fills whole screen
    CGPathAddRect(maskPath, nil, CGRectMake(0, 0, view.frame.width, height))
    
    /*
    If not even-odd, the next layer will just be
    placed over previous mask and not subtract it
    */
    maskLayer.fillRule = "even-odd"
    
    let radius = CGFloat(ZOOM_RADIUS[mappy.zoom])
    let x = CGFloat(Double(view.frame.width / 2) - Double(radius / 2))
    let y = CGFloat(Double(height / 2) - Double(radius / 2))
  
    // Add Rectangle cutout to path
    CGPathAddRoundedRect(maskPath, nil, CGRectMake(x, y, radius, radius), CGFloat(radius / 2), CGFloat(radius / 2))
    
    maskLayer.path = maskPath
    blurView.layer?.mask = maskLayer
    blurView.layer?.zPosition = 1
    /*
    Make sure map-reset-button is placed on top
    of map-mask
    */
    mapLocationImageView.layer?.zPosition = 2
    blurView.updateLayer()
  }

}