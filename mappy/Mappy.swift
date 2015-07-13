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

internal class NotificationScriptMessageHandler: NSObject, WKScriptMessageHandler {
  
  func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
    expose(message: message)
  }
  
  var expose: (message: WKScriptMessage) -> Void
  
  init(_ expose: (message: WKScriptMessage) -> Void) {
    self.expose = expose
  }
}

public class Mappy {
  
  static private let appID: String = {
    if
      let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist"),
      let dict = NSDictionary(contentsOfFile: path),
      let id = dict["API key"] as? String {
      return id
    }
    print("missing app id"); exit(0)
    
    }()
  
  static private func html(coordinates: CLLocationCoordinate2D) -> String {
    if
      let path = NSBundle.mainBundle().pathForResource("main", ofType: "html"),
      let markup = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil) {
        return markup
          .stringByReplacingOccurrencesOfString("@{appID}", withString: appID)
          .stringByReplacingOccurrencesOfString("@{longitude}", withString: "\(coordinates.longitude)")
          .stringByReplacingOccurrencesOfString("@{latitude}", withString: "\(coordinates.latitude)")
    }
    print("no markup"); exit(0)
  }
  
  private var _webView: WKWebView?
  
  private var previousLocation: CLLocationCoordinate2D?
  
  var webView: WKWebView {
    get {
      if _webView == nil {
        print("webView not set"); exit(0)
      }
      return _webView!
    }
    set(view) {
      _webView = view
    }
  }
  
}

public extension Mappy {
  
  func setView(frame: NSRect, coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 59.335004, longitude: 18.126813999999968)) -> WKWebView {
    
    let userContentController = WKUserContentController()
    let configuration = WKWebViewConfiguration()
    let handler = NotificationScriptMessageHandler(expose)
    let source = WKUserScript(source: Mappy.html(coordinates), injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
    
    userContentController.addUserScript(source)
    userContentController.addScriptMessageHandler(handler, name: "notification")
    configuration.userContentController = userContentController
    
    webView = WKWebView(frame: frame, configuration: configuration)
    
    loadMap(coordinates)
    
    return webView
  }
  
  func updateLocation(coordinates: CLLocationCoordinate2D) {
    previousLocation = coordinates
    let (lng, lat) = {
      return (coordinates.longitude, coordinates.latitude)
      }()
    js("var center = new google.maps.LatLng(\(lat), \(lng));" +
       "window.map.setZoom(13);" +
       "window.map.panTo(center);")
  }
  
  func resetToHome() {
    if let coordinates = previousLocation {
      updateLocation(coordinates)
    }
  }

}

private extension Mappy {
  
  func expose(message: WKScriptMessage) {
    println(message.body)
  }
  
  func loadMap(coordinates: CLLocationCoordinate2D) {
    let html = Mappy.html(coordinates)
    webView.loadHTMLString(html, baseURL: nil)
  }
  
  private func js(script: String) {
    webView.evaluateJavaScript(script, completionHandler: nil)
  }
}