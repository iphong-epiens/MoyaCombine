//
//  Utils.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/07/06.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation

class Utils {
  static let shared = Utils()

  struct Animations {
    static let duration = 0.25
    static let delay = 1.0
  }

  enum PagingMode: Int {
    case load = 0
    case loadMore
  }
  static let tableViewRowCount = 10

  static var encoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    return encoder
  }

  static var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    return decoder
  }

}

//extension Utils {
//  convenience init() {
//    self.init()
//  }
//}
