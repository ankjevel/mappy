//
//  Mappy.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-10.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Foundation
import WebKit
import CoreLocation

public class Mappy {

  static private let appID: String = {
    if
      let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist"),
      let dict = NSDictionary(contentsOfFile: path),
      let id = dict["API key"] as? String {
      return id
    }
    return ""
  }()
  
  static func html(coordinate: CLLocationCoordinate2D) -> String {
    return "" +
      "<!DOCTYPE html>" +
      "<html>" +
      "  <head>" +
      "    <style type=\"text/css\">" +
      "      html, body, #map-canvas { height: 100%; margin: 0; padding: 0;}" +
      "    </style>" +
      
      "    <script type=\"text/javascript\"" +
      "      src=\"https://maps.googleapis.com/maps/api/js?key=\(appID)\">" +
      "    </script>" +
      "    <script type=\"text/javascript\">" +
      "      function initialize() {" +
      "        var mapOptions = {" +
      "          center: {" +
      "           lat: \(coordinate.latitude)," +
      "           lng: \(coordinate.longitude)" +
      "          }," +
      "          zoom: 10," +
      "          panControl: false," +
      "          zoomControl: false," +
      "          mapTypeControl: false," +
      "          scaleControl: false," +
      "          streetViewControl: false," +
      "          overviewMapControl: false" +
      "        };" +
      "        var map = new google.maps.Map(document.getElementById('map-canvas')," +
      "            mapOptions);" +
      "      }" +
      "      google.maps.event.addDomListener(window, 'load', initialize);" +
      "    </script>" +
      "  </head>" +
      "  <body>" +
      "    <div id=\"map-canvas\"></div>" +
      "  </body>" +
      "</html>" +
    ""
  }
  
  let webView: WebView
  
  init(_ webView: WebView) {
    self.webView = webView
  }
}

public extension Mappy {
  func updateLocation(coordinate: CLLocationCoordinate2D) {
//      mappy.loadMap(CLLocationCoordinate2D(latitude: 59.335004, longitude: 18.126813999999968))
  }
}

private extension Mappy {
  func loadMap(coordinate: CLLocationCoordinate2D) {
    
    let html = Mappy.html(coordinate)
    
    webView.mainFrame.frameView.allowsScrolling = false
    webView.mainFrame.loadHTMLString(html, baseURL: nil)
  }
}