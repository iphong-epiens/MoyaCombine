//
//  NetworkType.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/03/18.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation
import Moya

public protocol NetworkType: TargetType, AccessTokenAuthorizable {}

public extension NetworkType {

  var baseURL: URL { return URL(string: Config.baseURL)! }

  var headers: [String: String]? { return nil }

  var method: Moya.Method { return .get }

  var authorizationType: AuthorizationType { return .bearer }

  var sampleData: Data { return Data() }

  var parameterEncoding: ParameterEncoding {
    return URLEncoding.default
  }
}
