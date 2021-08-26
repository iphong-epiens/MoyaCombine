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

  var userSysId: String!

  var accessToken: String? {
    guard let accessToken = try? KeyChain.getString("accessToken") else { return  nil }
    return accessToken
  }

  var authSysId: Int? {
    guard let authSysId = try? KeyChain.getString("authSysId"), let authSysId = Int(authSysId)  else { return  nil }
    return authSysId
  }

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
