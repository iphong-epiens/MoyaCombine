//
//  Utils.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/07/06.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation
import KeychainAccess
import JWTDecode
import SwiftyRSA

class Utils {
  static let shared = Utils()

  var isNetworkStub: Bool = false

  var userSysId: String!

  var accessToken: String? {
    guard let accessToken = try? KeyChain.getString("accessToken") else { return  nil }
    return accessToken
  }

  var refreshToken: String? {
    guard let refreshToken = try? KeyChain.getString("refreshToken") else { return  nil }
    return refreshToken
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

  // encrypt with public key
  // MARK: - encryptRsaString
  func encryptRsaString(_ encodeStr: String) -> String? {
    do {
      let publickeyStr = try KeyChain.getString("publicKey")
      guard let publickey = publickeyStr else { return nil }

      let publicKey = try PublicKey(base64Encoded: publickey)

      let clear = try ClearMessage(string: encodeStr, using: .utf8)
      let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
      let encrptedStr = Optional(encrypted.base64String)

      return encrptedStr
    } catch {
      print(error)
      return nil
    }
  }

  func networkLoading(_ loading: Bool) {
    let sender = NetworkLoadingNotificationSender(loading)
    NotificationCenter.default.post(name: NetworkLoadingNotificationSender.notification, object: sender)
  }

  func networkPopup(_ msg: String) {
    let sender = NetworkInfoNotificationSender(msg)
    NotificationCenter.default.post(name: NetworkInfoNotificationSender.notification, object: sender)
  }
}

//extension Utils {
//  convenience init() {
//    self.init()
//  }
//}
