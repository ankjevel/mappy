//
//  ResponseView.swift
//  mappy
//
//  Created by Dennis Pettersson on 2015-07-23.
//  Copyright (c) 2015 dennisp.se. All rights reserved.
//

import Cocoa

protocol ResponseViewDelegate: NSTableViewDelegate {
  func dataSource() -> NSTableViewDataSource?
}

class ResponseView: NSTableView {
  
  var delegate: ResponseViewDelegate?
}
