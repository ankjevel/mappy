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

public class MapView: WKWebView {
  
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
  
  static private let LATITUDE = 59.335004
  static private let LONGITUDE = 18.126813999999968
  var zoom = 13
  var mapUpdated: (Bool) -> Void
 
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
  
  init(_ mapUpdated: (Bool) -> Void) {
    self.mapUpdated = mapUpdated
  }
}

public extension Mappy {
  
  func setView(frame: NSRect, coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: LATITUDE, longitude: LONGITUDE)) -> WKWebView {
    
    let userContentController = WKUserContentController()
    let configuration = WKWebViewConfiguration()
    let handler = NotificationScriptMessageHandler(expose)
    let source = WKUserScript(source: Mappy.html(coordinates), injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
    
    userContentController.addUserScript(source)
    userContentController.addScriptMessageHandler(handler, name: "notification")
    configuration.userContentController = userContentController
    
    webView = MapView(frame: frame, configuration: configuration)
    
    loadMap(coordinates)
    
    return webView
  }
  
  func updateLocation(coordinates: CLLocationCoordinate2D) {
    previousLocation = coordinates
    let (lng, lat) = {
      return (coordinates.longitude, coordinates.latitude)
      }()
    zoom = 13
    js("var center = new google.maps.LatLng(\(lat), \(lng));" +
       "window.map.setZoom(\(zoom));" +
       "window.map.panTo(center);")
    getImages(coordinates)
  }
  
  func resetToHome() {
    if let coordinates = previousLocation {
      updateLocation(coordinates)
    }
  }
}

private extension Mappy {
  
  func dispatchRequest(request: NSURLRequest, callback out: (Dictionary<String, AnyObject>?, NSError?) -> Void)  {
    func handleResponse(data: NSData!, urlResponse: NSURLResponse!, error: NSError!) {
      var jsonErrorOptional: NSError?
      let json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonErrorOptional)
      if jsonErrorOptional != nil {
        return out(nil, jsonErrorOptional)
      }
      
      out(json as? Dictionary<String, AnyObject>, nil)
    }
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: handleResponse)
    
    task.resume()
  }
  
  func request(url: NSURL) -> NSMutableURLRequest {
    var request = NSMutableURLRequest(URL: url)
    request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    return request
  }
  
  func expose(message: WKScriptMessage) {
    var zoomUpdated = false
    if
      let body = message.body as? NSDictionary {
        if
          let center = body.objectForKey("center") as? [String: Double] {
            let longitude = center[center.indexForKey("A")!].1
            let latitude = center[center.indexForKey("F")!].1
//            println("longitude: \(longitude), latitude: \(latitude)")
        }
        if let zoom = body.objectForKey("zoom") as? Int {
          self.zoom = zoom
          zoomUpdated = true
//          println("zoom", zoom)
        }
    } else {
      println("not catched \(message.body)")
    }
    
    self.mapUpdated(zoomUpdated)
  }
  
  func getImages(coordinates: CLLocationCoordinate2D) {
    let url = NSURL(string: "http://instagrannar.se:3000" +
                            "/pictures" +
                            "?lng=\(coordinates.longitude)" +
                            "&lat=\(coordinates.latitude)")!
    let req = request(url)
////    QUERIES instagrannar for images in location
//    dispatchRequest(req) { (json, error) in
//      if error != nil || json == nil {
//        return
//      }
//      println(json!)
//    }
  }
  
  func loadMap(coordinates: CLLocationCoordinate2D) {
    let html = Mappy.html(coordinates)
    webView.loadHTMLString(html, baseURL: nil)
    getImages(coordinates)
  }
  
  private func js(script: String) {
    webView.evaluateJavaScript(script, completionHandler: nil)
  }
}