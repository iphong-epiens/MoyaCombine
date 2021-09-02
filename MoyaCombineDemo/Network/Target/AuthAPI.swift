//
//  Auth.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/03/24.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation
import Moya

extension ReqAPI {
  struct Auth {
    static let basePath = "auth/"

    // login API
    struct login: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any]) {
        self.parameters = params
      }

      var path: String { basePath + "login" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
      }
    }

    struct adminLogin: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any]) {
        self.parameters = params
      }

      var path: String { basePath + "admins/login" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
      }
    }

    // SNS Sign Up
    struct snslogin: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any]) {
        self.parameters = params
      }

      var path: String { basePath + "snslogin" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
      }
    }

    // retauthmine
    struct retauthmine: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any]) {
        self.parameters = params
      }

      var path: String { basePath + "retauthmine" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
      }
    }

    // sendauthmine
    struct sendauthmine: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any]) {
        self.parameters = params
      }

      var path: String { basePath + "sendauthmine" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
      }
    }

    // chkauthmine
    struct chkauthmine: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any]) {
        self.parameters = params
      }

      var path: String { basePath + "chkauthmine" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
      }
    }

    // join
    struct join: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any]) {
        self.parameters = params
      }

      var path: String { basePath + "join" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
      }
    }

    // public key
    struct publickey: ReqType {
      var authorizationType: AuthorizationType? {
        return .none
      }
      var sampleData: Data {
        return Data(
          """
          {
                                    jsonData":{"res":{"publicKey":"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA27Bf/sFXPg8cXgLp/n3tqTfKIZ/lcxO3I4K0NfXTXNm49KDmUofzntTS8bPvgcX688ZJRYDwig6a5ZmFE8FFSCdqJuUQ1c9UjnlU4KA7ztHDdPgd+zxCn9+lfaYgDXvwjXQb0t53u001VX5s/eTxsFri9qvMmdDQT4McYN1nIAUsDBDxPAkBQy4+CEddqWCjPLptqdroEUIgQ6fxrVVVzhuIpiG9zcSr/1RLbw6YERBxbVk/Q/CrgC5fKXWYRI5T4+V9MX4BxVvpqR2B+KEfxYQsXvJ2nyV0tKtb+m2hu+HtE4onsoM/lbm0Hw6yMKp/P2MofIyFNTdWeBcyEI3aRwIDAQAB"},"code":200,"resultCode":"0001","resultMsg":"Success"
                                    }
          }
          """.utf8
        )
      }

      var path: String { basePath + "publickey" }
      var method: Moya.Method { return .get }
      var task: Task {
        return .requestPlain
      }
    }

    struct chkrsa: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any]) {
        self.parameters = params
      }

      var path: String { basePath + "chkrsa" }
      var method: Moya.Method { return .post }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
      }
    }
  }
}
