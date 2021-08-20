//
//  Marvel.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/08/13.
//

import Foundation
import Moya

public enum Marvel {
  static private let publicKey = "a3c77f3df011888fe61fe1064f8f5032"
  static private let privateKey = "700a7043cd5fa654facf11ab211d4cf198a66e42"

  case comics
}

extension Marvel: TargetType {
  // 1
  public var baseURL: URL {
    return URL(string: "https://gateway.marvel.com/v1/public")!
  }

  // 2
  public var path: String {
    switch self {
    case .comics: return "/comics"
    }
  }

  // 3
  public var method: Moya.Method {
    switch self {
    case .comics: return .get
    }
  }

  // 4
  public var sampleData: Data {
    return Data()
  }

  // 5
  public var task: Task {
    let ts = "\(Date().timeIntervalSince1970)"
    // 1
    let hash = (ts + Marvel.privateKey + Marvel.publicKey).md5

    // 2
    let authParams = ["apikey": Marvel.publicKey, "ts": ts, "hash": hash]

    switch self {
    case .comics:
      // 3
      return .requestParameters(
        parameters: [
          "format": "comic",
          "formatType": "comic",
          "orderBy": "-onsaleDate",
          "dateDescriptor": "lastWeek",
          "limit": 50] + authParams,
        encoding: URLEncoding.default)
    }
  }

  // 6
  public var headers: [String: String]? {
    return ["Content-Type": "application/json"]
  }

  // 7
  public var validationType: ValidationType {
    return .successCodes
  }
}
