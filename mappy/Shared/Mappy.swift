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

protocol MappyDelegate: class {
  func mapEvent(zoom: Bool)
  func newElements(elements: [ResponseElement])
}

public class Mappy: NSObject {
  //MARK: - static stored properties
  
  static private let ZOOM_RADIUS = [0, 5000, 4500, 4000, 3500, 2900, 2400, 2000, 1750, 1500, 1250, 1000, 750, 500, 350, 200, 175, 125, 100, 75, 40, 20]
  // Long/Lat will place user in Stockholm by default
  static private let LATITUDE = 59.335004
  static private let LONGITUDE = 18.126813999999968
  /// Read API KEY from config
  static private let APP_ID: String = {
    if
      let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist"),
      let dict = NSDictionary(contentsOfFile: path),
      let id = dict["API key"] as? String {
      return id
    }
    print("missing app id", terminator: ""); exit(0)
    
    }()
  /**
  Returns main.html from file and replaces
  strings with given values
  */
  static private func HTML(coordinates: CLLocationCoordinate2D) -> String {
    if
      let path = NSBundle.mainBundle().pathForResource("main", ofType: "html"),
      let markup = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding) {
        return markup
          .stringByReplacingOccurrencesOfString("@{appID}", withString: APP_ID)
          .stringByReplacingOccurrencesOfString("@{longitude}", withString: "\(coordinates.longitude)")
          .stringByReplacingOccurrencesOfString("@{latitude}", withString: "\(coordinates.latitude)")
    }
    print("no markup", terminator: ""); exit(0)
  }
  
  /**
  Keeping track of where the user was located last. Value
  Gets updated if user moves more than what's defined in
  `CLLocationManagerDelegate.distanceFilter`
  */
  private var previousLocation: CLLocationCoordinate2D?
  /// This is what `webView` returns
  private var _webView: WKWebView?
  /// If _webView is not set, application will terminate
  private var webView: WKWebView {
    get {
      if _webView == nil {
        print("webView not set", terminator: ""); exit(0)
      }
      return _webView!
    }
    set(view) {
      _webView = view
    }
  }
  
  //MARK: - public stored properties
  /// Keeping track of what the current zoom level is at
  var zoom = 13
  var zoomRadius: Int {
    get {
      let max = Mappy.ZOOM_RADIUS.count
      if self.zoom > 0 && self.zoom <= max {
        return Mappy.ZOOM_RADIUS[self.zoom]
      } else {
        return 0
      }
    }
  }
  /// Public property for returning webView
  var view: WKWebView {
    get {
      return webView
    }
  }
  
  var delegate: MappyDelegate?
  
  private weak var timer: NSTimer?
  
  static private let TEMP_FOLDER: String = {
    let folder = NSString(string: "~/tmp").stringByExpandingTildeInPath
    let fm = NSFileManager()
    if fm.fileExistsAtPath(folder) == false {
      do {
        try fm.createDirectoryAtPath(folder, withIntermediateDirectories: true, attributes: nil)
      } catch _ {
      }
    }
    return folder
    }()
  static private let TEMP_TEXT_FILE: String! = {
    return NSURL(string: Mappy.TEMP_FOLDER)?.URLByAppendingPathComponent("response.txt").absoluteString
    }()
  
  private var _tempTextData: NSData? = {
    if let contents = NSData(contentsOfFile: Mappy.TEMP_TEXT_FILE) {
      return contents
    } else {
      return nil
    }
    }()
  
  private var tempTextData: NSData? {
    get {
      return _tempTextData
    }
    set(value) {
      _tempTextData = value
    }
  }
}

//MARK: - public
public extension Mappy {
  
  func initView(frame: NSRect, coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: LATITUDE, longitude: LONGITUDE)) {
    
    let userContentController = WKUserContentController()
    let configuration = WKWebViewConfiguration()
    let handler = NotificationScriptMessageHandler(expose)
    let source = WKUserScript(source: Mappy.HTML(coordinates), injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
    
    userContentController.addUserScript(source)
    userContentController.addScriptMessageHandler(handler, name: "notification")
    configuration.userContentController = userContentController
    
    webView = WKWebView(frame: frame, configuration: configuration)
    
    loadMap(coordinates)
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

  func dispatchRequest(timer: NSTimer) {
    // QUERIES instagrannar for images in location
    if
      let userInfo = timer.userInfo as? [String],
      let urlString = userInfo.first,
      let url = NSURL(string: urlString)
    {
      dispatchRequest(request(url)) { (json, error) in
        if error != nil ||
          json == nil ||
          json?.isEmpty == true {
          return
        }
        self.delegate?.newElements(self.parseRequest(json!))
      }
    }
  }
  
}

//MARK: - private
private extension Mappy {
  
  func parseRequest(json: [String: AnyObject]) -> [ResponseElement] {
    var elements: [ResponseElement] = []
    if let data = json["data"] as? [[String: AnyObject]] {
      let _ = data.first as [String: AnyObject]!
      for unwrapped in data {
        elements.append(ResponseElement(data: unwrapped))
      }
    }
    
    return elements
  }
  
  func dispatchRequest(request: NSURLRequest, callback out: ([String: AnyObject]?, NSError?) -> Void)  {
    func handleResponse(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
      parseNSData(data!, callback: out)
    }
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: handleResponse)
    task.resume()
  }

  /// Temporary override
//  func dispatchRequest(request: NSURLRequest, callback out: ([String: AnyObject]?, NSError?) -> Void)  {
//    func handleResponse(data: NSData!, urlResponse: NSURLResponse!, error: NSError!) {
//      data.writeToFile(Mappy.TEMP_TEXT_FILE, atomically: false)
//      tempTextData = data
//      parseNSData(data, callback: out)
//    }
//    if let data = tempTextData {
//      parseNSData(data, callback: out)
//    } else {
//      let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: handleResponse)
//      task.resume()
//    }
//  }
  
  func parseNSData(data: NSData, callback out: ([String: AnyObject]?, NSError?) -> Void) {
    var jsonErrorOptional: NSError?
    let json: AnyObject!
    do {
      json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
    } catch let error as NSError {
      jsonErrorOptional = error
      json = nil
    }
    if jsonErrorOptional != nil {
      return out(nil, jsonErrorOptional)
    }
    out(json as? [String: AnyObject], nil)
  }
  
  
  func request(url: NSURL) -> NSMutableURLRequest {
    let request = NSMutableURLRequest(URL: url)
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
            let longitude = center[center.indexForKey("F")!].1
            let latitude = center[center.indexForKey("A")!].1
            getImages(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        if let zoom = body.objectForKey("zoom") as? Int {
          self.zoom = zoom
          zoomUpdated = true
        }
    } else {
      print("not catched \(message.body)")
    }
    delegate?.mapEvent(zoomUpdated)
  }
  
  func getImages(coordinates: CLLocationCoordinate2D) {
    timer?.invalidate()
    let dst = zoomRadius
    let position = "?lng=\(coordinates.longitude)&lat=\(coordinates.latitude)&dst=\(dst)"
//    let position = "?lng=\(coordinates.longitude)&lat=\(coordinates.latitude)"
    let userInfo = [
      "http://instagrannar.se:3000" +
        "/pictures" +
        "\(position)" +
      ""]
    timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "dispatchRequest:", userInfo: userInfo, repeats: false)
  }
  
  func loadMap(coordinates: CLLocationCoordinate2D) {
    let html = Mappy.HTML(coordinates)
    webView.loadHTMLString(html, baseURL: nil)
    getImages(coordinates)
  }
  
  private func js(script: String) {
    webView.evaluateJavaScript(script, completionHandler: nil)
  }
}