//
//  APIClient.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/08/16.
//

import Foundation
import Moya
import RxSwift
import KeychainAccess
import JWTDecode
import SwiftyRSA
import Alamofire
import Combine
import CombineMoya
import SwiftDate

enum SwsApiError: Error {
  case refreshTokenError
  case accessTokenError
  case publicKeyError
}

public class API: ObservableObject {

  public struct NetworkClient {
    public var token: String? // We should persist this value

    // MARK: - Property
    let provider: MoyaProvider<MultiTarget>
    var cancellables = Set<AnyCancellable>()

    var lastTokenDate: Date?
    var cache = [String: Any]()

    public var tokenIsValid: Bool {
      //        if !Settings.shared.getBool(.didLogin) { return false }
      guard let tokenExpireDate = lastTokenDate else { return false }

      //refresh token 만료 시점에서 몇일전에 refresh token을 업데이트할지 설정
      //refresh token 4주 후 종료되며, 50% 남은 2주 후 업데이트 한다.
      let updateIntervalDay: TimeInterval = 14

      // Refresh Token 만료일자 보다 14일 이전 날짜 계산
      let updateDate = Date(timeInterval: -86400*updateIntervalDay, since: tokenExpireDate)
      print("updateDate", updateDate)

      //업데이트 날짜가 현재 날짜보다 미래인지 체크
      let interval = updateDate.timeIntervalSince1970 - Date().timeIntervalSince1970

      let daysInterval = Int(floor(interval/86400))
      print("refresh token next update remains of", daysInterval, "day")

      return daysInterval > 0 ? true : false
    }

    init(provider: MoyaProvider<MultiTarget>) {
      self.provider = provider
      do {
        if let refreshToken = try KeyChain.getString("refreshToken") {
          print("saved refresh token", refreshToken)
          let jwt = try decode(jwt: refreshToken)
          guard let expDate = jwt.expiresAt else {return}
          self.lastTokenDate = expDate
          print("refresh token expire date", self.lastTokenDate!.toString())
        }
      } catch let error {
        print(error.localizedDescription)
      }
    }
  }

  /// Default api client
  // static -> lazy하게 생성 // let -> thread-safe 보장
  static let shared: NetworkClient = {

    //plugIn Config

    let networkClosure = {(_ change: NetworkActivityChangeType, _ target: TargetType) in
      DispatchQueue.main.async {

        switch change {
        case .began:
          API.shared.networkLoading(true)
        case .ended:
          API.shared.networkLoading(false)
        }
      }
    }

    let logOptions: NetworkLoggerPlugin.Configuration = NetworkLoggerPlugin.Configuration(logOptions: .verbose)

    let plugIn: [PluginType] = [NetworkLoggerPlugin(configuration: logOptions), NetworkActivityPlugin(networkActivityClosure: networkClosure), AccessTokenPlugin(tokenClosure: { _ in
      var accessToken: String {
        guard let token = try? KeyChain.getString("accessToken") else { return "" }
        print("saved Token", token)
        return token
      }

      return accessToken
    })]

    // Session Config
    var configuration: URLSessionConfiguration {
      let config = URLSessionConfiguration.default
      config.timeoutIntervalForRequest = 5
      config.timeoutIntervalForResource = 5
      config.requestCachePolicy = .useProtocolCachePolicy
      return config
    }

    let sessionConfig = Session(configuration: configuration, startRequestsImmediately: false)

    let provider = MoyaProvider<MultiTarget>(session: sessionConfig, plugins: plugIn)
    let client = NetworkClient(provider: provider)

    return client
  }()

  // API singleton
  // private 권한을 설정하여 외부에서 인스턴스를 생성할 수 없게 함
  private init() {}
}

extension API.NetworkClient {
  func request<Request: TargetType>(_ request: Request) -> AnyPublisher<Moya.Response, Error> {
    let target = MultiTarget(request)

    return self.provider.requestPublisher(target)
      .subscribe(on: DispatchQueue.global(qos: .background))
      .receive(on: DispatchQueue.global(qos: .background))
      .tryCatch({ error -> AnyPublisher<Moya.Response, Error> in
        // 401 Error, update access token
        if let response = error.response,
           let statusCode = HTTPStatusCode(rawValue: response.statusCode),
           statusCode == .unauthorized {
          return self.fetchAccessToken(target: target)
        } else {
          throw error
        }
      })
      .handleEvents(receiveOutput: { response in
        print(response.statusCode)
      }, receiveCompletion: { completion in
        print(completion)
        switch completion {
        case .finished:
          break
        case .failure(let error):
          self.networkPopup(error.localizedDescription)
        }
      })
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  func networkLoading(_ loading: Bool) {
    let sender = NetworkLoadingNotificationSender(loading)
    NotificationCenter.default.post(name: NetworkLoadingNotificationSender.notification, object: sender)
  }

  func networkPopup(_ msg: String) {
    let sender = NetworkInfoNotificationSender(msg)
    NotificationCenter.default.post(name: NetworkInfoNotificationSender.notification, object: sender)
  }

  // MARK: - fetchAccessToken
  func fetchAccessToken(target: MultiTarget) -> AnyPublisher<Moya.Response, Error> {
    API.shared.request(ReqAPI.Token.accessToken(Utils.shared.refreshToken ?? ""))
      .tryMap({
        if $0.statusCode == 401 {
          throw SwsApiError.accessTokenError
        }
        return $0
      })
      .tryCatch({ error -> AnyPublisher<Moya.Response, Error> in
        if let error = error as? SwsApiError, error == SwsApiError.accessTokenError {
          throw SwsApiError.accessTokenError
        } else {
          throw error
        }
      })
      .handleEvents(receiveOutput: { response in
        if let resultData = try? response.map(AccessTokenRespData.self) {
          print(">>> fetchAccessToken resultData", resultData)
          do {
            try KeyChain.set(resultData.jsonData.accessToken, key: "accessToken")
            try KeyChain.set("\(resultData.jsonData.authSysId)", key: "authSysId")
          } catch let error {
            print(error.localizedDescription)
          }
        }
      }, receiveCompletion: { completion in
        print(completion)
        switch completion {
        case .failure(let error):
          if let error = error as? SwsApiError {
            switch error {
            case .accessTokenError:
              do {
                try KeyChain.remove("accessToken")
                try KeyChain.remove("refreshToken")

                // go login menu
                UserDefaults.standard.setValue(false, forKey: "isLoggedIn")

                API.shared.networkPopup("refresh token error")
              } catch let error {
                print("error: \(error)")
              }

            default:
              break
            }
          }

        case .finished:
          break
        }
      })
      .flatMap { _ in
        //retry actual request
        self.request(target)
      }
      .eraseToAnyPublisher()
  }

  // MARK: - fetchRefreshToken

  func fetchRefreshToken(_ refreshToken: String) {
    var cancellables = Set<AnyCancellable>()

    API.shared.request(ReqAPI.Token.refreshToken(refreshToken))
      .sink(receiveCompletion: { completion in
        switch completion {
        case .failure(let error):
          print(error.localizedDescription)

          do {
            try KeyChain.remove("accessToken")
            try KeyChain.remove("refreshToken")

            API.shared.networkPopup("refresh token error")

            // go login menu
            UserDefaults.standard.setValue(false, forKey: "isLoggedIn")
          } catch let error {
            print("error: \(error)")
          }

        case .finished:
          // Refresh Token 갱신 후 public key도 추가로 갱신한다.
          self.fetchPublicKey()
        }
      }, receiveValue: { response in
        do {
          if let resultData = try? response.map(RefreshTokenRespData.self) {
            print(">>> fetchRefreshToken resultData", resultData)

            try KeyChain.set(resultData.jsonData.accessToken, key: "accessToken")
            try KeyChain.set(resultData.jsonData.refreshToken, key: "refreshToken")
            try KeyChain.set("\(resultData.jsonData.authSysId)", key: "authSysId")

            print("changed refreshToken:", resultData.jsonData.refreshToken, "changed accessToken:", resultData.jsonData.accessToken, "authSysId", resultData.jsonData.authSysId)
          }
        } catch let error {
          print(error.localizedDescription)
        }
      }).store(in: &cancellables)
  }

  // MARK: - fetchPublicKey

  func fetchPublicKey() {
    var cancellables = Set<AnyCancellable>()

    API.shared.request(ReqAPI.Auth.publickey())
      .print()
      .sink(receiveCompletion: { completion in
        print(completion)
      }, receiveValue: { response in
        do {
          let json = try response.mapJSON()
          if let object = json as? [String: Any],
             let resultData = object["jsonData"],
             let jsonData = resultData as? [String: Any],
             let res = jsonData["res"]  as? [String: Any],
             let publicKey = res["publicKey"] as? String {
            //save public key
            try KeyChain.set(publicKey, key: "publicKey")
            print("new publicKey:", publicKey)
          }
        } catch let error {
          print(error.localizedDescription)
        }
      })
      .store(in: &cancellables)
  }

  func checkRSA(encodedStr: String) {
    var cancellables = Set<AnyCancellable>()

    let checkRSAData = ChkRsaReqData(rsaEncStr: encodedStr)
    let jsonChkRSAEncodeData = try? Utils.encoder.encode(checkRSAData)
    guard let jsonData = jsonChkRSAEncodeData, let jsonString = String(data: jsonData, encoding: .utf8) else { return }

    API.shared.request(ReqAPI.Auth.chkrsa(jsonString.toParams))
      .map { $0.data }
      .decode(type: ChkRsaRespData.self, decoder: JSONDecoder())
      .sink(receiveCompletion: { completion in
        print(completion)
        switch completion {
        case .finished:
          break

        case .failure(let error):
          print(error.localizedDescription)
        }
      }, receiveValue: { response in
        print(response.jsonData.res.rsaDecStr)
      })
      .store(in: &cancellables)
  }
}
