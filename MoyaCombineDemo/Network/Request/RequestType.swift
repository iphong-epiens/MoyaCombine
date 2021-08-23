//
//  RequestType.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/03/24.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation
import Moya

public protocol ReqType: TargetType, AccessTokenAuthorizable {
  var parameters: [String: Any] { get }
}

extension ReqType {
  var baseURL: URL { return URL(string: Config.baseURL)! }

  var headers: [String: String]? { return nil }

  var method: Moya.Method { return .get }

  public var sampleData: Data { return Data() }
  public var parameters: [String: Any] { return [:] }

  var authorizationType: AuthorizationType { return .bearer }

  var parameterEncoding: ParameterEncoding {
    return URLEncoding.default
  }
}

public struct ReqAPI {}
