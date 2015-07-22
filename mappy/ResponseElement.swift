//
//  ResponseElement
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-22.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Foundation
import AppKit

internal func parseDictionary(dictionary: [String: String]) -> String {
  if
    let data = NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted, error: nil),
    let json = NSString(data: data, encoding: NSUTF8StringEncoding) {
      return json as String
  } else {
    return ""
  }
}

internal enum ResponseElementType: String, Printable {
  case Image = "image"
  case Video = "video"
  case Other = "other"
  
  init(_ type: String) {
    switch type.lowercaseString {
    case "image":
      self = .Image
      break
    case "video":
      self = .Video
      break
    default:
      self = .Other
    }
  }
  
  var description: String {
    get {
      return self.rawValue
    }
  }
}

struct ResponseElementImage: Printable {
  
  let width: Int
  let height: Int
  let url: NSURL
  
  init(_ data: [String: AnyObject]? = nil) {
    if let unwrappedData = data {
      if let width = unwrappedData["width"] as? Int {
        self.width = width
      } else {
        self.width = 0
      }
    
      if
        let url = unwrappedData["url"] as? String,
        let unwrapped = NSURL(string: url)
      {
        self.url = unwrapped
      } else {
        self.url = NSURL()
      }
    
      if let height = unwrappedData["height"] as? Int {
        self.height = height
      } else {
        self.height = 0
      }
    } else {
      self.url = NSURL()
      self.width = 0
      self.height = 0
    }
  }
  
  var description: String {
    get {
      let description: [String: String] = [
        "width": "\(width)",
        "height": "\(height)",
        "url": "\(url)"
      ]
      return "\(description)"
    }
  }
}

struct ResponseElementImages: Printable {
  
  let low: ResponseElementImage
  let standard: ResponseElementImage
  let thumbnail: ResponseElementImage
  
  init(_ data: [String: AnyObject?]? = nil) {
    if let dataUnwrapped = data {
      self.low = ResponseElementImage(dataUnwrapped["low_resolution"] as! [String: AnyObject]?)
      self.standard = ResponseElementImage(dataUnwrapped["standard_resolution"] as! [String: AnyObject]?)
      self.thumbnail = ResponseElementImage(dataUnwrapped["thumbnail"] as! [String: AnyObject]?)
    } else {
      self.low = ResponseElementImage()
      self.standard = ResponseElementImage()
      self.thumbnail = ResponseElementImage()
    }
  }
  
  var description: String {
    get {
      let description: [String: String] = [
        "low": "\(low)",
        "standard": "\(standard)",
        "thumbnail": "\(thumbnail)"
      ]
      return "\(description)"
    }
  }
}

struct ResponseElement: Printable {
  let type: ResponseElementType
  let link: NSURL
  let user: String
  let images: ResponseElementImages
  
  init(data: [String: AnyObject?]) {
    if let type = data["type"] as? String {
      self.type = ResponseElementType(type)
    } else {
      self.type = .Other
    }
    
    if let link = data["link"] as? String {
      self.link = NSURL(string: link)!
    } else {
      self.link = NSURL()
    }
    
    if
      let user = data["user"] as? [String: AnyObject],
      let username = user["username"] as? String {
      self.user = username
    } else {
      self.user = ""
    }
    
    if let images = data["images"] as? [String: AnyObject] {
      self.images = ResponseElementImages(images)
    } else {
      self.images = ResponseElementImages()
    }
  }
  
  var description: String {
    get {
      let description: [String: String] = [
        "type": "\(type)",
        "link": "\(link)",
        "user": "\(user)",
        "images": "\(images)"
      ]
      return parseDictionary(description)
    }
  }
}