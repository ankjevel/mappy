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
class MapHolderViewController: NSViewController, NSSplitViewDelegate, CLLocationManagerDelegate, MappyDelegate {
  
  /// How sensitive `CLLocationManager` will be
  private let MINIMUM_DISTANCE_IN_METERS = 10.0
  /// Zoom radius based on "feelings"
  private let ZOOM_RADIUS = [1, 1, 1, 1, 1, 1, 1, 2, 5, 10, 15, 35, 70, 120, 250, 480, 980, 1850, 3700, 7400, 14800, 29600]
  
  private let locationManager = CLLocationManager()
  private let mappy = Mappy()
  
  @IBOutlet weak var sharedView: NSSplitView!
  
  /// Container for map-related `NSView` and elements
  @IBOutlet weak var topView: NSView!
  /// Google maps-view
  @IBOutlet weak var mapView: NSView!
  /// Effect layer for "blur" over map
  @IBOutlet weak var blurView: NSVisualEffectView!
  /// Border for map-location
  @IBOutlet weak var mapLocationBorder: NSView!
  
  @IBOutlet weak var bottomView: NSView!
  @IBOutlet weak var elementsListView: NSScrollView!
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
  
  func newElements(elements: [ResponseElement]) {
  }
  
  func splitView(splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
    mask()
    return true
  }
  
  func splitView(splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
    return 100.0
  }
  
  func splitView(splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
    if let height = view.window?.frame.height {
      return CGFloat(height - 20.0)
    } else {
      return 100.0
    }
  }
  
  /**
  Evaluate if the mask over the map needs to update
  it's size or just redrawn
  
  :param: zoom
  true if the zoom has been updated
  */
  func mapEvent(zoom: Bool) {
    if zoom {
      mask()
    } else {
      blurView.updateLayer()
    }
  }
  
  // Initialize the view
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageBorder()
    
    sharedView.delegate = self
    mappy.delegate = self

    // Will set `Mappy.view`
    mappy.initView(topView.frame)
    // Will replace previous map-view-placeholder
    let newMapView = mappy.view
    /*
    But just to be safe, copy previous frame from
    xib file
    */
    newMapView.frame = mapView.frame
    
    topView.replaceSubview(mapView, with: newMapView)
    mapView = newMapView
    
    mapView.layer?.zPosition = 0
    blurView.layer?.setNeedsLayout()
    blurView.alphaValue = 0.70
    
    setConstraints(&mapView!)
    
    locationManager.delegate = self
    locationManager.distanceFilter = MINIMUM_DISTANCE_IN_METERS
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
    
    mask()
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
  
  func imageBorder() {
    var maskLayer = CAShapeLayer()
    var maskPath = CGPathCreateMutable()
    let frame = mapLocationBorder.frame
    let w = frame.width
    
    let r = CGFloat(max(mapLocationBorder.frame.width, mapLocationBorder.frame.height))
    let x = CGFloat(Double(mapLocationBorder.frame.width / 2) - Double(r / 2))
    let y = CGFloat(Double(mapLocationBorder.frame.height / 2) - Double(r / 2))
    
    CGPathAddRoundedRect(maskPath, nil, CGRectMake(x, y, r, r), CGFloat(r / 2), CGFloat(r / 2))

    maskLayer.bounds = mapLocationBorder.bounds
    maskLayer.frame = mapLocationBorder.bounds
    
    maskLayer.path = maskPath
    
    maskLayer.fillColor = IOSColors.AZURE.CGColor
    if mapLocationBorder.layer != nil {
      mapLocationBorder.layer?.insertSublayer(maskLayer, atIndex: 0)
    } else {
      mapLocationBorder.layer = maskLayer
    }
    mapLocationBorder.updateLayer()
  }
  
  /**
  Add constraints to a view

  :param: view
    `NSView` used to add constraints to
  */
  func setConstraints(inout view: NSView) {
    // DO NOT FORGET THIS
    view.translatesAutoresizingMaskIntoConstraints = false
    topView.addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: topView, attribute: .Top, multiplier: 1, constant: 0))
    topView.addConstraint(NSLayoutConstraint(item: view, attribute: .Right, relatedBy: .Equal, toItem: topView, attribute: .Right, multiplier: 1, constant: 0))
    topView.addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: topView, attribute: .Bottom, multiplier: 1, constant: 0))
    topView.addConstraint(NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: topView, attribute: .Left, multiplier: 1, constant: 0))
  }
  
  /// Draws the mask over the map (into `blurView`)
  func mask() {
    var maskLayer = CAShapeLayer()
    var maskPath = CGPathCreateMutable()
    
    // Subtract toolbar height from frame height
    let h = topView.frame.height
    let w = topView.frame.width
    
    // Add initial mask that fills whole screen
    CGPathAddRect(maskPath, nil, CGRectMake(0, 0, w, h))
    
    /*
    If not even-odd, the next layer will just be
    placed over previous mask and not subtract it
    */
    maskLayer.fillRule = "even-odd"
    
    let radius = CGFloat(ZOOM_RADIUS[mappy.zoom])
    let x = CGFloat(Double(w / 2) - Double(radius / 2))
    let y = CGFloat(Double(h / 2) - Double(radius / 2))
  
    // Add Rectangle cutout to path
    CGPathAddRoundedRect(maskPath, nil, CGRectMake(x, y, radius, radius), CGFloat(radius / 2), CGFloat(radius / 2))
    
    maskLayer.path = maskPath
    blurView.layer?.mask = maskLayer
    blurView.layer?.zPosition = 1
    /*
    Make sure map-reset-button is placed on top
    of map-mask
    */
    mapLocationBorder.layer?.zPosition = 2
    blurView.updateLayer()
  }

}