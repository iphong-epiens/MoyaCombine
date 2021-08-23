//
//  Config.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/02/24.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation

struct Config {
  #if RELEASE
  static let baseURL = "https://shallwe.link:3800/api/v1"
  #elseif STAGING
  static let baseURL = "https://shallwe.link:3500/api/v1"
  #else
  static let baseURL = "https://shallwe.link:3000/api/v1"
  #endif
}
