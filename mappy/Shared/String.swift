//
//  String.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-24.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Foundation

extension String {
  
  func substringFromIndex(index: Int) -> String {
    return self.substringFromIndex(self.startIndex.advancedBy(index))
  }
  
  func contains(value: String, caseInsensitive: Bool = true) -> Bool {
    if caseInsensitive {
      return self.lowercaseString.rangeOfString(value.lowercaseString) != nil
    } else {
      return self.rangeOfString(value) != nil
    }
  }
}