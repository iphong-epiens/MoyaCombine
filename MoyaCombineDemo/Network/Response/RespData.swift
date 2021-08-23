//
//  RespData.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/03/13.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation

protocol RespDataType: Codable {
  var code: Int { get }
  var resultCode: String { get }
  var resultMsg: String? { get }
}

struct ResultData: RespDataType {
  var code: Int
  var resultCode: String
  var resultMsg: String?

  private enum CodingKeys: String, CodingKey {
    case code
    case resultCode
    case resultMsg
  }
}

struct RespData: Codable {
  let jsonData: ResultData

  private enum CodingKeys: String, CodingKey {
    case jsonData
  }
}
