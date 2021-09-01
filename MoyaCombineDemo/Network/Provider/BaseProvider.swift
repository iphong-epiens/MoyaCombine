//
//  BaseProvider.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/09/01.
//

import Foundation
import Moya

class BaseProvider<T: TargetType>: MoyaProvider<T> {

  init(stubClosure: @escaping StubClosure = MoyaProvider.neverStub) {

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

    /// make provider
    super.init(stubClosure: stubClosure,
               session: sessionConfig,
               plugins: plugInConfig)
  }
}
