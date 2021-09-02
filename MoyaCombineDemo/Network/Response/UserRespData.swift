//
//  UserRespData.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/04/02.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation

struct CheckDuplicateIdRespData: ResultDataType {
  var code: Int
  var resultCode: String
  var resultMsg: String?

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case resultMsg
  }
}

struct MyInfoResultData: ResultDataType {
  var code: Int
  var resultCode: String
  var resultMsg: String?
  var joinTypeCode: Int
  var userSysId: Int
  var profileImgUrl: String?
  var userId: String
  var nickName: String
  var mobile: String
  var name: String?
  var gender: String?
  var birthday: String?

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case resultMsg
    case joinTypeCode
    case userSysId
    case profileImgUrl
    case userId
    case nickName
    case mobile
    case name
    case gender
    case birthday
  }
}

struct MyInfoRespData: Codable {
  let jsonData: MyInfoResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}

struct UserInfoResultData: ResultDataType {
  var code: Int
  var resultCode: String
  var resultMsg: String?
  var userSysId: Int
  var userId: String
  var name: String?
  var nickName: String?
  var profile: String?
  var profileImgUrl: String?
  var birthday: String?
  var mobile: String
  var genderCode: Int?
  var joinTypeCode: Int
  var address1: String?
  var address2: String?
  var point: Int
  var rewardAmount: Int
  var totalPurchase: Int
  var connectionCount: Int
  var isBlock: Int
  var isDrop: Int
  var isDormancy: Int
  var isDelete: Int
  var userGradeSysId: Int
  var blockedAt: String?
  var droppedAt: String?
  var dormancyAt: String?
  var deletedAt: String?
  var createdAt: String
  var updatedAt: String
  var cbSilenceCnt: Int
  var cbForcedExitCnt: Int
  var cbPermanentCnt: Int

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case resultMsg
    case userSysId
    case userId
    case name
    case nickName
    case profile
    case profileImgUrl
    case birthday
    case mobile
    case genderCode
    case joinTypeCode
    case address1
    case address2
    case point
    case rewardAmount
    case totalPurchase
    case connectionCount
    case isBlock
    case isDrop
    case isDormancy
    case isDelete
    case userGradeSysId
    case blockedAt
    case droppedAt
    case dormancyAt
    case deletedAt
    case createdAt
    case updatedAt
    case cbSilenceCnt
    case cbForcedExitCnt
    case cbPermanentCnt
  }
}

struct UserInfoRespData: Codable {
  let jsonData: UserInfoResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}

struct ReviewInfoResultData: ResultDataType {
  var code: Int
  var resultCode: String
  var startIndex: Int?
  var reviews: [Review]?
  var resultMsg: String?

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case startIndex
    case reviews
    case resultMsg
  }
}

struct ReviewInfoRespData: Codable {
  let jsonData: ReviewInfoResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}

struct Review: Codable {
  let prdtSysId: Int
  let bigImageUrl: String
  let middleImageUrl: String
  let smallImageUrl: String
  let brandSysId: Int
  let brandName: String
  let name: String
  let prdtReviewSysId: Int
  let reviewType: Int
  let starPoint: Int
  let oneLine: String
  let content: String
  let recommendCnt: Int
  let deprecatedCnt: Int
  let mediaCnt: Int
  let photoCnt: Int

  private enum CodingKeys: String, CodingKey {
    case prdtSysId
    case bigImageUrl
    case middleImageUrl
    case smallImageUrl
    case brandSysId
    case brandName
    case name
    case prdtReviewSysId
    case reviewType
    case starPoint
    case oneLine
    case content
    case recommendCnt
    case deprecatedCnt
    case mediaCnt
    case photoCnt
  }
}
