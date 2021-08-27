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
import CryptoSwift
import JWTDecode
import KeychainAccess
import CryptoSwift
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

struct ResultCodeError: Error {
  static func with(domain: String, code: Int = 0, localizedDescription: String) -> Error {
    return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: localizedDescription]) as Error
  }
}

public class API: ObservableObject {
  public var target: MultiTarget?
  public struct NetworkClient {
    public var token: String? // We should persist this value

    // MARK: - Property
    let provider: MoyaProvider<MultiTarget>
    var cancellables = Set<AnyCancellable>()

    var lastTokenDate: Date?
    var cache = [String: Any]()

    public var hasValidRefreshToken: Bool {
      //        if !Settings.shared.getBool(.didLogin) { return false }
      guard let tokenExpireDate = lastTokenDate else { return false }

      // Refresh Token 만료일자 보다 14일 이전 날짜 계산
      let updateDate = Date(timeInterval: -86400*14, since: tokenExpireDate)
      print("updateDate", updateDate)

      //업데이트 날짜가 현재 날짜보다 미래인지 체크
      let interval = updateDate.timeIntervalSince1970 - Date().timeIntervalSince1970

      let daysInterval = floor(interval/86400)
      print("refresh token next update remains of", Int(daysInterval), "day")

      return interval < 0 ? true : false
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

    var configuration: URLSessionConfiguration {
      let config = URLSessionConfiguration.default
      config.timeoutIntervalForRequest = 5
      config.timeoutIntervalForResource = 5
      config.requestCachePolicy = .useProtocolCachePolicy
      return config
    }

    let sessionConfig = Session(configuration: configuration, startRequestsImmediately: false)
    let logOptions: NetworkLoggerPlugin.Configuration = NetworkLoggerPlugin.Configuration(logOptions: .verbose)

    let plugIn: [PluginType] = [NetworkLoggerPlugin(configuration: logOptions), NetworkActivityPlugin(networkActivityClosure: networkClosure), AccessTokenPlugin(tokenClosure: { _ in
      var accessToken: String {
        guard let token = try? KeyChain.getString("accessToken") else { return "" }
        print("saved Token", token)
        return token
      }

      return accessToken
    })]

    let provider = MoyaProvider<MultiTarget>(plugins: plugIn)
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
        if let response = error.response {
          let statusCode = HTTPStatusCode(rawValue: response.statusCode)
          switch statusCode {
          // access token error
          case .unauthorized:
            print(">>> access token error")
            return API.shared.fetchAccessToken(target: target)

          default:
            break
          }
        }
        return API.shared.request(target)
      })
      .handleEvents(receiveOutput: { response in
        print(response.statusCode)
      }, receiveCompletion: { completion in
        print(completion)
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

  // MARK: - requestErrorHandler
  //  func requestErrorHandler(_ error: SwsApiError, target: MultiTarget) {
  //    print(">>> SwsApiError", error)
  //    switch error {
  //    case .refreshTokenError:
  //      print("refreshTokenError")
  //      self.changeRefreshToken(target: target)
  //
  //    case .accessTokenError:
  //      print("accessTokenError")
  //      self.fetchAccessToken(target: target)
  //
  //    case .publicKeyError:
  //      print("publicKeyError")
  //      self.changePublicKey(target: target)
  //    }
  //  }

  // MARK: - fetchAccessToken
  func fetchAccessToken(target: MultiTarget) -> AnyPublisher<Moya.Response, Error> {

    API.shared.request(ReqAPI.Token.accessToken(Utils.shared.refreshToken ?? ""))
      .tryMap({
        if $0.statusCode == 401 {
          throw SwsApiError.refreshTokenError
        }
        return $0
      })
      .tryCatch({ error -> AnyPublisher<Moya.Response, Error> in
        if let error = error as? SwsApiError, error == SwsApiError.refreshTokenError {
          return self.fetchRefreshToken(target: target)
        } else {
          throw SwsApiError.accessTokenError
        }
      })
      .handleEvents(receiveOutput: { response in
        if let resultData = try? response.map(AccessTokenRespData.self) {
          print(">>> fetchAccessToken resultData", resultData)
          do {
            try KeyChain.set(resultData.jsonData.accessToken, key: "accessToken")
          } catch let error {
            print(error.localizedDescription)
          }
        }
      }, receiveCompletion: { completion in
        print(completion)
        switch completion {
        case .failure(let error):
          print(error)

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

  // MARK: - changeRefreshToken

  func fetchRefreshToken(target: MultiTarget) -> AnyPublisher<Moya.Response, Error> {
    //fetchRefreshToken
    API.shared.request(ReqAPI.Token.refreshToken(Utils.shared.refreshToken ?? ""))
      .tryMap({
        if $0.statusCode == 401 {
          throw SwsApiError.refreshTokenError
        }
        return $0
      })
      .tryCatch({ error -> AnyPublisher<Moya.Response, Error> in
        if let error = error as? SwsApiError, error == SwsApiError.refreshTokenError {
          return self.fetchRefreshToken(target: target)
        } else {
          throw SwsApiError.refreshTokenError
        }
      })
      .handleEvents(receiveOutput: { response in
        do {
          if let resultData = try? response.map(RefreshTokenRespData.self) {
            print(">>> fetchRefreshToken resultData", resultData)
          }

          let json = try response.mapJSON()

          if let object = json as? [String: Any],
             let jsonData = object["jsonData"] as? [String: Any],
             let code = jsonData["code"] as? Int {

            let statusCode = HTTPStatusCode(rawValue: code)

            switch statusCode {
            case .ok:
              guard let code = jsonData["resultCode"] as? String else { return }
              let resultCode = ResultCode(rawValue: code)

              switch resultCode {
              case .success:
                if let refreshToken = jsonData["refreshToken"] as? String, let accessToken = jsonData["accessToken"] as? String {
                  try KeyChain.set(refreshToken, key: "refreshToken")
                  try KeyChain.set(accessToken, key: "accessToken")

                  NotificationCenter.default.post(name: Notification.Name("updateAccessTokenEvent"), object: accessToken)
                  print("changed refreshToken:", refreshToken, "changed accessToken:", accessToken)
                }

              default:
                break
              }

            case .unauthorized:
              print(#function, "unauthorized")
              do {
                try KeyChain.remove("accessToken")
                try KeyChain.remove("refreshToken")

                API.shared.networkPopup("refresh token error")

                // go login menu
                UserDefaults.standard.setValue(false, forKey: "isLoggedIn")
              } catch let error {
                print("error: \(error)")
              }

            default:
              break
            }
          }
        } catch let error {
          print(error.localizedDescription)
        }
      }, receiveCompletion: { completion in
        switch completion {
        case .failure(let error):
          print(error)

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

  //  func changeRefreshToken(target: MultiTarget) {
  //    //Change Refresh Token
  //    guard let refreshToken = try? KeyChain.getString("refreshToken") else { return }
  //
  //    var cancellables = Set<AnyCancellable>()
  //
  //    API.shared.request(ReqAPI.Token.refreshToken(refreshToken))
  //      .print()
  //      .sink(receiveCompletion: { completion in
  //        print(completion)
  //      }, receiveValue: { response in
  //        do {
  //          let json = try response.mapJSON()
  //
  //          if let object = json as? [String: Any],
  //             let jsonData = object["jsonData"] as? [String: Any],
  //             let code = jsonData["code"] as? Int {
  //
  //            let statusCode = HTTPStatusCode(rawValue: code)
  //
  //            switch statusCode {
  //            case .ok:
  //              guard let code = jsonData["resultCode"] as? String else { return }
  //              let resultCode = ResultCode(rawValue: code)
  //
  //              switch resultCode {
  //              case .success:
  //                if let refreshToken = jsonData["refreshToken"] as? String, let accessToken = jsonData["accessToken"] as? String {
  //                  try KeyChain.set(refreshToken, key: "refreshToken")
  //                  try KeyChain.set(accessToken, key: "accessToken")
  //
  //                  NotificationCenter.default.post(name: Notification.Name("updateAccessTokenEvent"), object: accessToken)
  //
  //                  print("changed refreshToken:", refreshToken, "changed accessToken:", accessToken)
  //                  _ = self.request(target)
  //                }
  //
  //              default:
  //                break
  //              }
  //
  //            case .unauthorized:
  //              print(#function, "unauthorized")
  //              do {
  //                try KeyChain.remove("accessToken")
  //                try KeyChain.remove("refreshToken")
  //                //                    Settings.shared.setBool(.didLogin, value: false)
  //                //                    Settings.shared.setBool(.autoLogin, value: false)
  //                //
  //                //                    alert(AppDelegate.topmost, "refresh token error", isCancelable: false)
  //              } catch let error {
  //                print("error: \(error)")
  //              }
  //
  //            default:
  //              break
  //            }
  //          }
  //        } catch let error {
  //          print(error.localizedDescription)
  //        }
  //      }).store(in: &cancellables)
  //  }

  // MARK: - changePublicKey

  func changePublicKey(target: MultiTarget) {
    //Change Public Key
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
            print("changed publicKey:", publicKey)

            _ = self.request(target)
          }
        } catch let error {
          print(error.localizedDescription)
        }
      }).store(in: &cancellables)
  }

  // MARK: - getPublicKey

  func getPublicKey() {
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

  // encrypt with public key
  // MARK: - encryptRsaString
  func encryptRsaString(_ encodeStr: String) -> String? {
    do {
      let publickeyStr = try KeyChain.getString("publicKey")
      guard let publickey = publickeyStr else { return nil }

      let publicKey = try PublicKey(base64Encoded: publickey)

      let clear = try ClearMessage(string: encodeStr, using: .utf8)
      let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
      let encrptedStr = Optional(encrypted.base64String)

      return encrptedStr
    } catch {
      print(error)
      return nil
    }
  }
}
