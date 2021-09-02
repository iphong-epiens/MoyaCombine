//
//  ProviderProtocol.swift
//  MoyaTestCase
//
//  Created by Inpyo Hong on 2021/08/31.
//

import Foundation
import Combine
import Moya
import RxSwift
import RxMoya
import CombineMoya

/*
 iOS Networking and Testing
 https://techblog.woowahan.com/2704/
 */

public protocol ProviderProtocol: AnyObject {
  associatedtype T: TargetType
  var provider: MoyaProvider<T> { get }
  init(isStub: Bool, sampleStatusCode: Int, customEndpointClosure: ((T) -> Endpoint)?)
}

public extension ProviderProtocol {

  static func consProvider(
    _ isStub: Bool = false,
    _ sampleStatusCode: Int = 200,
    _ customEndpointClosure: ((T) -> Endpoint)? = nil) -> MoyaProvider<T> {

    if isStub == false {
      /// PlugIn Config
      var plugInConfig: [PluginType] {
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

      /// Session Config
      var sessionConfig: Session {
        var configuration: URLSessionConfiguration {
          let config = URLSessionConfiguration.default
          config.timeoutIntervalForRequest = 5
          config.timeoutIntervalForResource = 5
          config.requestCachePolicy = .useProtocolCachePolicy
          return config
        }
        return Session(configuration: configuration, startRequestsImmediately: false)
      }

      return MoyaProvider<T>(
        endpointClosure: {
          MoyaProvider<T>.defaultEndpointMapping(for: $0).adding(newHTTPHeaderFields: [:])
        },
        session: sessionConfig,
        plugins: plugInConfig
      )
    } else {
      // 테스트 시에 호출되는 stub 클로져
      let endPointClosure = { (target: T) -> Endpoint in
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

      return MoyaProvider<T>(
        endpointClosure: customEndpointClosure ?? endPointClosure,
        stubClosure: MoyaProvider.immediatelyStub
      )
    }
  }
}

extension ProviderProtocol {
  func request<D: Decodable>(type: D.Type, atKeyPath keyPath: String? = nil, target: T) -> Single<D> {
    provider.rx.request(target)
      .map(type, atKeyPath: keyPath)
    // some operators
  }

  func request<D: Decodable>(type: D.Type, atKeyPath keyPath: String? = nil, target: T) -> AnyPublisher<D, MoyaError> {
    provider.requestPublisher(target)
      .map(type, atKeyPath: keyPath)
      .eraseToAnyPublisher()
    // some operators
  }
}
