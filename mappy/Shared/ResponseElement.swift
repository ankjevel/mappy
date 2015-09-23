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
    let data = try? NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted),
    let json = NSString(data: data, encoding: NSUTF8StringEncoding) {
      return json as String
  } else {
    return ""
  }
}

enum ResponseElementType: String, CustomStringConvertible {
  
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

struct ResponseElementImage: CustomStringConvertible {
  
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
        self.url = NSURL(string: "")!
      }
      
      if let height = unwrappedData["height"] as? Int {
        self.height = height
      } else {
        self.height = 0
      }
    } else {
      self.url = NSURL(string: "")!
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

struct ResponseElementImages: CustomStringConvertible {
  
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

struct ResponseElementProfile: CustomStringConvertible {
  
  let picture: NSURL
  let username: String
  let id: Int
  
  init(_ data: [String: AnyObject?]? = nil) {
    if
      let unwrappedData = data,
      let user = unwrappedData["user"] as? [String: AnyObject]
    {
      if let username = user["username"] as? String {
        self.username = username
      } else {
        self.username = ""
      }
      
      if let id = user["id"] as? String {
        self.id = Int(id)!
      } else {
        self.id = Int.max
      }
      
      if
        let profile = user["profile_picture"] as? String,
        let url = NSURL(string: profile)
      {
        self.picture = url
      } else {
        self.picture = NSURL(string: "")!
      }
      
    } else {
      self.picture = NSURL(string: "")!
      self.username = ""
      self.id = 0
    }
  }
  
  var description: String {
    get {
      let description: [String: String] = [
        "picture": "\(picture)",
        "username": "\(username)",
        "id": "\(id)"
      ]
      return "\(description)"
    }
  }
  
}

/*
protocol GenericResponseElementType {
  typealias T
  
  init(_ T: NSURL)
  init(_ T: Int)
  init(_ T: String)
  init(_ T: Double)
  init(_ T: ResponseElementProfile)
  init(_ T: ResponseElementType)
  init(_ T: ResponseElementImages)
}
*/

public class ResponseElement: CustomStringConvertible {
  
  let type: ResponseElementType
  let link: NSURL
  let profile: ResponseElementProfile
  let images: ResponseElementImages
  let latitude: Double
  let longitude: Double
  let caption: String
  
  func getAttributeByString(value: String) -> Any {
    
    func returnImageAttribute(image: ResponseElementImage) -> Any {
      if value.contains(".url") {
        return image.url
      }
      if value.contains(".height") {
        return image.height
      }
      if value.contains(".width") {
        return image.width
      }
      return ""
    }
    
    if value.contains("profile.") {
      switch value.stringByReplacingOccurrencesOfString("profile.", withString: "") {
      case "picture":
        return self.profile.picture
      case "username":
        return self.profile.username
      case "id":
        return self.profile.id
      default:
        return ""
      }
    }

    if value.contains("images.") {
      if value.contains(".low.") {
        return returnImageAttribute(self.images.low)
      }
      if value.contains(".standard.") {
        return returnImageAttribute(self.images.standard)
      }
      if value.contains(".thumbnail.") {
        return returnImageAttribute(self.images.thumbnail)
      }
      return ResponseElementImage()
    }
    
    switch value.lowercaseString {
    case "type":
      return self.type
    case "link":
      return self.link
    case "latitude":
      return self.latitude
    case "longitude":
      return self.longitude
    case "caption":
      return self.caption
    case "profile":
      return self.profile
    case "images":
      return self.images
    default:
      return self
    }
  }
  
  init(data: [String: AnyObject?]) {
    
    if let type = data["type"] as? String {
      self.type = ResponseElementType(type)
    } else {
      self.type = .Other
    }
    
    if let link = data["link"] as? String {
      self.link = NSURL(string: link)!
    } else {
      self.link = NSURL(string: "")!
    }
    
    self.profile = ResponseElementProfile(data)
    
    if let images = data["images"] as? [String: AnyObject] {
      self.images = ResponseElementImages(images)
    } else {
      self.images = ResponseElementImages()
    }
    
    if let location = data["location"] as? [String: AnyObject] {
      if let longitude = location["longitude"] as? Double {
        self.longitude = longitude
      } else {
        self.longitude = 0.0
      }
      
      if let latitude = location["latitude"] as? Double {
        self.latitude = latitude
      } else {
        self.latitude = 0.0
      }
    } else {
      self.longitude = 0.0
      self.latitude = 0.0
    }
    
    if
      let caption = data["caption"] as? [String: AnyObject],
      let text = caption["text"] as? String
    {
      self.caption = text
    } else {
      self.caption = ""
    }
  }
  
  public var description: String {
    get {
      let description: [String: String] = [
        "type": "\(type)",
        "link": "\(link)",
        "profile": "\(profile)",
        "images": "\(images)",
        "latitude": "\(latitude)",
        "longitude": "\(longitude)"
      ]
      return parseDictionary(description)
    }
  }
}