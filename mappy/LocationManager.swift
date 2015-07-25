//
//  LocationManager.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-23.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: CLLocationManager {
  
  override var delegate: CLLocationManagerDelegate! {
    didSet(delegate) {
      self.startUpdatingLocation()
    }
  }
  
  override init() {
    super.init()
    self.distanceFilter = 10.0
    self.desiredAccuracy = kCLLocationAccuracyBest
  }
}