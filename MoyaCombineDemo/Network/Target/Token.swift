//
//  Token.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/03/25.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation
import Moya

extension ReqAPI {
  struct Token {
    static let basePath = "auth/"
    // accessToken
    struct accessToken: ReqType {
      var refreshToken: String

      //bearer에 access token이 아니라 refresh token을 넣기 때문에, none으로 처리함.
      var authorizationType: AuthorizationType? {
        return .none
      }

      var headers: [String: String]? {
        var httpHeaders: [String: String] = [:]
        httpHeaders["Authorization"] = "Bearer " + self.refreshToken
        return httpHeaders
      }

      init(_ refreshToken: String) {
        self.refreshToken = refreshToken
      }

      var path: String { basePath + "accesstoken" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestPlain
      }
    }

    struct adminAcessToken: ReqType {
      var refreshToken: String

      var authorizationType: AuthorizationType? {
        return .none
      }

      var headers: [String: String]? {
        var httpHeaders: [String: String] = [:]
        httpHeaders["Authorization"] = "Bearer " + self.refreshToken
        return httpHeaders
      }

      init(_ refreshToken: String) {
        self.refreshToken = refreshToken
      }

      var path: String { basePath + "admins/accesstoken" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestPlain
      }
    }

    // refreshToken
    struct refreshToken: ReqType {
      var refreshToken: String

      var authorizationType: AuthorizationType? {
        return .none
      }

      var headers: [String: String]? {
        var httpHeaders: [String: String] = [:]
        httpHeaders["Authorization"] = "Bearer " + self.refreshToken
        return httpHeaders
      }

      init(_ refreshToken: String) {
        self.refreshToken = refreshToken
      }
      var path: String { basePath + "refresh" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestPlain
      }
    }

    struct adminRefreshToken: ReqType {
      var refreshToken: String

      var authorizationType: AuthorizationType? {
        return .none
      }

      var headers: [String: String]? {
        var httpHeaders: [String: String] = [:]
        httpHeaders["Authorization"] = "Bearer " + self.refreshToken
        return httpHeaders
      }

      init(_ refreshToken: String) {
        self.refreshToken = refreshToken
      }
      var path: String { basePath + "admins/refresh" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestPlain
      }
    }
  }
}
