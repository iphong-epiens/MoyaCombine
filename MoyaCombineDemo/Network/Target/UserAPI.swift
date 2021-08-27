//
//  User.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/03/25.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation
import Moya

extension ReqAPI {
  struct User {
    static let basePath = "users/"

    // SNS Login Add Info API
    struct addinfo: ReqType {
      var parameters: [String: Any]
      var accessToken: String
      var authSysId: String

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any], accessToken: String, authSysId: String) {
        self.parameters = params
        self.accessToken = accessToken
        self.authSysId = authSysId
      }

      var path: String { basePath + authSysId + "/" + "addinfo" }

      var headers: [String: String]? {
        var httpHeaders: [String: String] = [:]
        httpHeaders["Authorization"] = "Bearer " + self.accessToken
        return httpHeaders
      }

      var method: Moya.Method { return .patch }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default) //기본 body encoding
      }

      public var validationType: ValidationType {
        return .successCodes
      }
    }

    // get user info API
    struct getMyinfo: ReqType {
      var authorizationType: AuthorizationType? {
        return .bearer
      }

      var authSysId: String
      var path: String { basePath + authSysId + "/" + "myinfo" }
      var method: Moya.Method { return .get }
      var task: Task {
        return .requestPlain
      }

      init(authSysId: String) {
        self.authSysId = authSysId
      }

      public var validationType: ValidationType {
        return .successCodes
      }
    }

    //chagne my info
    struct setMyinfo: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .bearer
      }

      var authSysId: String
      var path: String { basePath + authSysId + "/" + "myinfo" }
      var method: Moya.Method { return .patch }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
      }

      init(_ params: [String: Any], authSysId: String) {
        self.parameters = params
        self.authSysId = authSysId
      }

      public var validationType: ValidationType {
        return .successCodes
      }
    }

    struct getUerInfo: ReqType {
      //      var accessToken: String
      var userSysId: Int

      var authorizationType: AuthorizationType? {
        return .bearer
      }

      //      var headers: [String: String]? {
      //        var httpHeaders: [String: String] = [:]
      //        httpHeaders["Authorization"] = "Bearer " + self.accessToken
      //        return httpHeaders
      //      }

      var path: String { basePath + "\(userSysId)" }

      var method: Moya.Method { return .get }
      var task: Task {
        return .requestPlain
      }

      init(userSysId: Int) {
        //        self.accessToken = accessToken
        self.userSysId = userSysId
      }

      public var validationType: ValidationType {
        return .successCodes
      }
    }

    struct password: ReqType {
      var parameters: [String: Any]
      var authToken: String

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any], authToken: String) {
        self.parameters = params
        self.authToken = authToken
      }

      var path: String { basePath + "password" }

      var headers: [String: String]? {
        var httpHeaders: [String: String] = [:]
        httpHeaders["Authorization"] = "Bearer " + self.authToken
        return httpHeaders
      }

      var method: Moya.Method { return .patch }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default) //기본 body encoding
      }

      public var validationType: ValidationType {
        return .successCodes
      }
    }

    struct MyReviewList: ReqType {
      var authSysId: String
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .bearer
      }

      var path: String { basePath + authSysId + "/reviews/list" }
      var method: Moya.Method { return .get }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString) //uri 방식
      }

      init(_ params: [String: Any], authSysId: String) {
        self.parameters = params
        self.authSysId = authSysId
      }

      public var validationType: ValidationType {
        return .successCodes
      }
    }

    // user id duplicate API
    struct CheckUpId: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any]) {
        self.parameters = params
      }

      var path: String { basePath + "chkdupid" }
      var method: Moya.Method { return .get }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString) //uri 방식
      }

      public var validationType: ValidationType {
        return .successCodes
      }
    }

    struct CheckUpNickName: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .none
      }

      init(_ params: [String: Any]) {
        self.parameters = params
      }

      var path: String { basePath + "chkdupnick" }
      var method: Moya.Method { return .get }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString) //uri 방식
      }

      public var validationType: ValidationType {
        return .successCodes
      }
    }

    struct ChangeUserPoints: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .bearer
      }

      var authSysId: String
      var path: String { basePath + authSysId + "/points" }
      var method: Moya.Method { return .patch }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default) //기본 body encoding
      }

      init(_ params: [String: Any], authSysId: String) {
        self.parameters = params
        self.authSysId = authSysId
      }

      public var validationType: ValidationType {
        return .successCodes
      }
    }

    struct setFcmToken: ReqType {
      var parameters: [String: Any]

      var authorizationType: AuthorizationType? {
        return .bearer
      }

      var userSysId: String
      var path: String { basePath + userSysId + "/push/token" }
      var method: Moya.Method { return .patch }
      var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
      }

      init(_ params: [String: Any], userSysId: String) {
        self.parameters = params
        self.userSysId = userSysId
      }

      public var validationType: ValidationType {
        return .successCodes
      }
    }
  }
}
