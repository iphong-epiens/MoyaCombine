//
//  UserReqData.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/04/02.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation

struct CheckDuplicateIdReqData: Codable {
  let userId: String

  private enum CodingKeys: String, CodingKey {
    case userId
  }
}

struct CheckNickNameReqData: Codable {
  let nickName: String

  private enum CodingKeys: String, CodingKey {
    case nickName
  }
}

struct MyReviewReqData: Codable {
  let startIndex: Int?
  let rowCount: Int?

  private enum CodingKeys: String, CodingKey {
    case startIndex
    case rowCount
  }
}

struct SnsAddInfoReqData: Codable {
  let mobile: String
  let agreeSellection1: Int?
  let agreeSellection2: Int?

  private enum CodingKeys: String, CodingKey {
    case mobile
    case agreeSellection1
    case agreeSellection2
  }
}

struct PasswordReqData: Codable {
  let password: String

  private enum CodingKeys: String, CodingKey {
    case password
  }
}

struct MyInfoReqData: Codable {
  let name: String?
  let genderCode: Int?
  let birthday: String?
  let profileImgUrl: String?

  private enum CodingKeys: String, CodingKey {
    case name
    case genderCode
    case birthday
    case profileImgUrl
  }
}

struct UserPointsReqData: Codable {
  let treatFlag: Int
  let point: Int
  let pointTypeCode: Int?

  private enum CodingKeys: String, CodingKey {
    case treatFlag
    case point
    case pointTypeCode
  }
}

struct UserFcmTokenData: Codable {
  let deviceToken: String

  private enum CodingKeys: String, CodingKey {
    case deviceToken
  }
}
