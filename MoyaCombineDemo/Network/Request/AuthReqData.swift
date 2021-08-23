//
//  AuthReqData.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/03/12.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation

struct AuthReqData: Codable {
  let authType: Int
  let authWay: Int
  let authWayValue: String
  let userId: String?

  private enum CodingKeys: String, CodingKey {
    case authType
    case authWay
    case authWayValue
    case userId
  }
}

struct SnsLoginReqData: Codable {
  let snsType: Int
  let snsToken: String
  let rcmdUserSysId: String?
  let facebookUserId: String?

  private enum CodingKeys: String, CodingKey {
    case snsType
    case snsToken
    case rcmdUserSysId
    case facebookUserId
  }
}

struct AuthCheckReqData: Codable {
  let authType: Int
  let authWay: Int
  let authWayValue: String
  let authNo: String
  let userId: String?

  private enum CodingKeys: String, CodingKey {
    case authType
    case authWay
    case authWayValue
    case authNo
    case userId
  }
}

struct JoinReqData: Codable {
  let userId: String
  let password: String
  let mobile: String
  let agreeSellection1: Int?
  let agreeSellection2: Int?
  let rcmdUserSysId: Int?

  private enum CodingKeys: String, CodingKey {
    case userId
    case password
    case mobile
    case agreeSellection1
    case agreeSellection2
    case rcmdUserSysId
  }
}

struct LoginReqData: Codable {
  let userId: String
  let password: String

  private enum CodingKeys: String, CodingKey {
    case userId
    case password
  }
}

struct AccessTokenReqData: Codable {
  let authType: Int
  let authWay: Int
  let authWayValue: String

  private enum CodingKeys: String, CodingKey {
    case authType
    case authWay
    case authWayValue
  }
}

struct ChkRsaReqData: Codable {
  let rsaEncStr: String

  private enum CodingKeys: String, CodingKey {
    case rsaEncStr
  }
}
