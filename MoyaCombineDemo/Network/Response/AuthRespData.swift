//
//  AuthRespData.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/03/13.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation

enum SnsLoginType: Int {
  case register = 0, login
}

enum SnsAddInfoType: Int {
  case notExist = 0, exist
}

enum CompanyType: Int, Codable {
  case headquarter = 1, seller, brand
}

struct AuthInfoData: Codable {
  let sendCnt: Int
  let authNo: String
  let limitDate: String

  private enum CodingKeys: String, CodingKey {
    case sendCnt
    case authNo
    case limitDate
  }
}

struct AuthResultData: RespDataType {
  var code: Int
  var resultCode: String
  var resultMsg: String?
  var res: AuthInfoData

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case resultMsg
    case res
  }
}

struct AuthRespData: Codable {
  let jsonData: AuthResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}

struct LoginResultData: RespDataType {
  var code: Int
  var resultCode: String
  var resultMsg: String?
  var authSysId: Int
  var accessToken: String
  var refreshToken: String

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case resultMsg
    case authSysId
    case accessToken
    case refreshToken
  }
}

struct LoginRespData: Codable {
  let jsonData: LoginResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}

protocol AdminLoginInfoable {
  var name: String { get }
  var companyTypeCode: CompanyType { get }
  var sellerSysId: Int? { get }
  var brandSysId: Int? { get }
  var gradeSysId: Int? { get }
}

struct AdminLoginResultData: RespDataType, AdminLoginInfoable {
  var code: Int
  var resultCode: String
  var resultMsg: String?
  var authSysId: Int
  var accessToken: String
  var refreshToken: String
  var name: String
  var companyTypeCode: CompanyType
  var sellerSysId: Int?
  var brandSysId: Int?
  var gradeSysId: Int?

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case resultMsg
    case authSysId
    case accessToken
    case refreshToken
    case name
    case companyTypeCode
    case sellerSysId
    case brandSysId
    case gradeSysId
  }
}

struct AdminLoginRespData: Codable {
  let jsonData: AdminLoginResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}

struct SnsLoginResultData: RespDataType {
  var code: Int
  var resultCode: String
  var resultMsg: String?
  var authSysId: Int
  var snsLoginType: Int
  var snsAddInfoFlag: Int
  var accessToken: String
  var refreshToken: String

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case resultMsg
    case authSysId
    case snsLoginType
    case snsAddInfoFlag
    case accessToken
    case refreshToken
  }
}

struct SnsLoginRespData: Codable {
  let jsonData: SnsLoginResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}

struct AccessTokenResultData: RespDataType {
  var code: Int
  var resultCode: String
  var resultMsg: String?
  var authSysId: Int
  var accessToken: String

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case resultMsg
    case authSysId
    case accessToken
  }
}

struct AccessTokenRespData: Codable {
  let jsonData: AccessTokenResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}

struct RefreshTokenResultData: RespDataType {
  var code: Int
  var resultCode: String
  var resultMsg: String?
  var authSysId: Int
  var accessToken: String
  var refreshToken: String

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case resultMsg
    case authSysId
    case accessToken
    case refreshToken
  }
}

struct RefreshTokenRespData: Codable {
  let jsonData: RefreshTokenResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}

struct ChkRsaResultData: RespDataType {
  var code: Int
  var resultCode: String
  var resultMsg: String?
  var res: RsaDecData

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case resultMsg
    case res
  }
}

struct RsaDecData: Codable {
  let rsaDecStr: String
}

struct ChkRsaRespData: Codable {
  let jsonData: ChkRsaResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}

struct PublicKeyRespData: Codable {
  let jsonData: PublicKeyResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}

struct PublicKeyResultData: RespDataType {
  var code: Int
  var resultCode: String
  var resultMsg: String?
  var res: PublicKeyData
}

struct PublicKeyData: Codable {
  let publicKey: String
}
