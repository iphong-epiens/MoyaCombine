//
//  NetworkManager.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/09/02.
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

class NetworkManager {

  // MARK: - Property
  var provider: MoyaProvider<MultiTarget>!
  var cancellables = Set<AnyCancellable>()

  var lastTokenDate: Date?

  public var tokenIsValid: Bool {
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

  init(isStub: Bool = false, sampleStatusCode: Int = 200, customEndpointClosure: ((TargetType) -> Endpoint)? = nil) {

    self.configRefreshToken()

    if isStub == false {
      self.provider = MoyaProvider<MultiTarget>(
        stubClosure: MoyaProvider.neverStub,
        session: self.configSession(),
        plugins: self.configPlugIns())
    } else {
      let endPointClosure = { (target: MultiTarget) -> Endpoint in
        let sampleResponseClosure: () -> EndpointSampleResponse = {
          EndpointSampleResponse.networkResponse(sampleStatusCode, target.sampleData)
        }

        return Endpoint(
          url: URL(target: target).absoluteString,
          sampleResponseClosure: sampleResponseClosure,
          method: target.method,
          task: target.task,
          httpHeaderFields: target.headers
        )
      }
      self.provider = MoyaProvider<MultiTarget>(
        endpointClosure: customEndpointClosure ?? endPointClosure,
        stubClosure: MoyaProvider.immediatelyStub
      )
    }
  }
}

extension NetworkManager {
  func requestDebug<T: TargetType, D: Decodable>(_ request: T, type: D.Type, atKeyPath keyPath: String? = nil) -> AnyPublisher<D, MoyaError> {
    let target = MultiTarget(request)

    return self.provider.requestPublisher(target)
      .map(type, atKeyPath: keyPath)
      .eraseToAnyPublisher()
  }

  func request<T: TargetType>(_ request: T) -> AnyPublisher<Moya.Response, Error> {
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
          Utils.shared.networkPopup(error.localizedDescription)
        }
      })
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

extension NetworkManager {
  // MARK: - fetchAccessToken
  func fetchAccessToken(target: MultiTarget) -> AnyPublisher<Moya.Response, Error> {
    self.request(ReqAPI.Token.accessToken(Utils.shared.refreshToken ?? ""))
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

                Utils.shared.networkPopup("refresh token error")
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

    self.request(ReqAPI.Token.refreshToken(refreshToken))
      .map { $0.data }
      .decode(type: RefreshTokenRespData.self, decoder: JSONDecoder())
      .sink(receiveCompletion: { completion in
        switch completion {
        case .failure(let error):
          print(error.localizedDescription)

          do {
            try KeyChain.remove("accessToken")
            try KeyChain.remove("refreshToken")

            Utils.shared.networkPopup("refresh token error")

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
        let resultData = response.jsonData
        do {
          try KeyChain.set(resultData.accessToken, key: "accessToken")
          try KeyChain.set(resultData.refreshToken, key: "refreshToken")
          try KeyChain.set("\(resultData.authSysId)", key: "authSysId")

          print("changed refreshToken:", resultData.refreshToken, "changed accessToken:", resultData.accessToken, "authSysId", resultData.authSysId)
        } catch let error {
          print(error.localizedDescription)
        }
      }).store(in: &cancellables)
  }

  // MARK: - fetchPublicKey

  func fetchPublicKey() {
    var cancellables = Set<AnyCancellable>()

    self.request(ReqAPI.Auth.publickey())
      .map { $0.data }
      .decode(type: PublicKeyRespData.self, decoder: JSONDecoder())
      .sink(receiveCompletion: { completion in
        print(completion)
      }, receiveValue: { response in
        do {
          try KeyChain.set(response.jsonData.res.publicKey, key: "publicKey")
          print("new publicKey:", response.jsonData.res.publicKey)
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

    self.request(ReqAPI.Auth.chkrsa(jsonString.toParams))
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

extension NetworkManager {
  private func configRefreshToken() {
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

  private func configPlugIns() -> [PluginType] {
    /// NetworkActivityPlugin
    let networkClosure = {(_ change: NetworkActivityChangeType, _ target: TargetType) in
      DispatchQueue.main.async {

        switch change {
        case .began:
          Utils.shared.networkLoading(true)
        case .ended:
          Utils.shared.networkLoading(false)
        }
      }
    }

    /// NetworkLoggerPlugin
    let logOptions: NetworkLoggerPlugin.Configuration = NetworkLoggerPlugin.Configuration(logOptions: .verbose)

    return [NetworkLoggerPlugin(configuration: logOptions), NetworkActivityPlugin(networkActivityClosure: networkClosure), AccessTokenPlugin(tokenClosure: { _ in
      var accessToken: String {
        guard let token = try? KeyChain.getString("accessToken") else { return "" }
        print("saved Token", token)
        return token
      }

      return accessToken
    })]
  }

  private func configSession() -> Session {
    /// Session Config
    var configuration: URLSessionConfiguration {
      let config = URLSessionConfiguration.default
      config.timeoutIntervalForRequest = 5
      config.timeoutIntervalForResource = 5
      config.requestCachePolicy = .useProtocolCachePolicy
      return config
    }
    return Session(configuration: configuration, startRequestsImmediately: false)
  }
}
