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
  
  static func html(coordinates: CLLocationCoordinate2D) -> String {
    return "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\" /><style type=\"text/css\">html, body, #map-canvas { height: 100%; margin: 0; padding: 0;}</style>" +
      
      "    <script src=\"https://maps.googleapis.com/maps/api/js?key=\(appID)\"></script>" +
      
      "    <script type=\"text/javascript\">" +
      "      window.map = {}; function initialize() {" +
      "        var mapOptions = {" +
      "          center: {" +
      "           lat: \(coordinates.latitude)," +
      "           lng: \(coordinates.longitude)" +
      "          }," +
      "          zoom: 10," +
      "          panControl: false," +
      "          zoomControl: false," +
      "          mapTypeControl: false," +
      "          scaleControl: false," +
      "          streetViewControl: false," +
      "          overviewMapControl: false" +
      "        };" +
      "        window.map = new google.maps.Map(document.getElementById('map-canvas')," +
      "            mapOptions);" +
      "      }" +
      "      google.maps.event.addDomListener(window, 'load', initialize);" +
      "    </script>" +
      
      "</head><body><div id=\"map-canvas\"></div></body></html>"
  }
  
  private var _webView: WebView?
  
  private var js: JSContext {
    get {
      return webView.mainFrame.javaScriptContext
    }
  }
  
  var webView: WebView {
    get {
      if _webView == nil {
        return WebView()
      }
      return _webView!
    }
    set(view) {
      _webView = view
    }
  }
}

public extension Mappy {
  
  /// Could not use init() for this class implementation
  /// Default long/lat is in Djurgården
  func setView(view: WebView, coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 59.335004, longitude: 18.126813999999968)) {
    self.webView = view
    loadMap(coordinates)
  }
  
  func updateLocation(coordinates: CLLocationCoordinate2D) {
    let (lng, lat) = {
      return (coordinates.longitude, coordinates.latitude)
      }()
    
    let newLocation = "" +
      "var center = new google.maps.LatLng(\(lat), \(lng));" +
      "window.map.panTo(center);" +
    ""
    
    js.evaluateScript(newLocation)
  }
}

private extension Mappy {
  
  func loadMap(coordinates: CLLocationCoordinate2D) {
    let html = Mappy.html(coordinates)
    
    webView.mainFrame.frameView.allowsScrolling = false
    webView.mainFrame.loadHTMLString(html, baseURL: nil)
  }
}