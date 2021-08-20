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
import PKHUD
import Alamofire
import Combine
import CombineMoya

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

final public class API: ObservableObject {
    
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
                //          if let refreshToken = try KeyChain.getString("refreshToken") {
                //            print("saved refresh token", refreshToken)
                //            let jwt = try decode(jwt: refreshToken)
                //            guard let expDate = jwt.expiresAt else {return}
                //            self.lastTokenDate = expDate
                //            print("refresh token expire date", self.lastTokenDate!.toString())
                //          }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    /// Default api client
    public static let shared: NetworkClient = {
        
        let networkClosure = {(_ change: NetworkActivityChangeType, _ target: TargetType) in
            DispatchQueue.main.async {
                switch change {
                case .began: break
                //HUD.show(.progress, onView: AppDelegate.root.view)
                case .ended:
                    HUD.hide(afterDelay: 1.0)
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
                //          guard let token = try? KeyChain.getString("accessToken") else { return "" }
                //          print("saved Token", token)
                return "" //token
            }
            
            return accessToken
        })]
        
        let provider = MoyaProvider<MultiTarget>(plugins: plugIn)
        let client = NetworkClient(provider: provider)
        
        return client
    }()
    
    // API singleton
    private init() {}
}

extension API.NetworkClient {
    func request<Request: TargetType>(_ request: Request) -> AnyPublisher<Moya.Response, Error> {
        let target = MultiTarget(request)
        
        return self.provider.requestPublisher(target)
            .tryMap{
                if self.hasValidRefreshToken {
                    throw SwsApiError.refreshTokenError
                }
                
                let json = try $0.mapJSON()
                
                if let object = json as? [String: Any], let resultData = object["jsonData"] as? [String: Any], let statusCode = resultData["code"] as? Int, let resultCode = resultData["resultCode"] as? String {
                    
                    let status = HTTPStatusCode(rawValue: statusCode)
                    let result = ResultCode(rawValue: resultCode)
                    
                    print((#function, statusCode))
                    
                    switch status {
                    case .ok:
                        switch result {
                        case .authError:
                            throw SwsApiError.accessTokenError
                            
                        case .publicKeyError:
                            throw SwsApiError.publicKeyError
                            
                        default:
                            break
                        }
                        
                    default:
                        break
                    }
                }
                
                return $0
            }
            .receive(on: DispatchQueue.global(qos: .background))
            .handleEvents(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("finished")
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    
                case .failure(let error as SwsApiError):
                    print(">>> SwsApiError", error)
                    switch error {
                    case .refreshTokenError:
                        print("refreshTokenError")
                        
                    case .accessTokenError:
                        print("accessTokenError")
                        
                    case .publicKeyError:
                        print("publicKeyError")
                    }
                }
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getPublicKey() {
        
        _ = self.request(ReqAPI.Auth.publickey())
            .sink(receiveCompletion: {
                print($0)
            }, receiveValue: {
                print($0)
            })
        
        
        
        //      return API.shared.request(ReqAPI.Auth.publickey())
        //        .print()
        //        .receive(on: DispatchQueue.global(qos: .background))
        ////        .handleEvents(receiveOutput: { ouput in
        ////            print(ouput)
        ////        }, receiveCompletion: { completion in
        ////            print(completion)
        ////        })
        //        .eraseToAnyPublisher()
        //        .subscribe(onSuccess: { response in
        //          do {
        //            let json = try response.mapJSON()
        //            if let object = json as? [String: Any],
        //               let resultData = object["jsonData"],
        //               let jsonData = resultData as? [String: Any],
        //               let res = jsonData["res"]  as? [String: Any],
        //               let publicKey = res["publicKey"] as? String {
        //              //save public key
        //              try KeyChain.set(publicKey, key: "publicKey")
        //              print("new publicKey:", publicKey)
        //              single(.success(response))
        //            }
        //          } catch let error {
        //            print(error.localizedDescription)
        //            single(.error(error))
        //          }
        //        }) { error in
        //          single(.error(error))
        //        }
        
    }
}
