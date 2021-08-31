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

public protocol ProviderProtocol: AnyObject {
    associatedtype T : TargetType
    var provider: MoyaProvider<MultiTarget> { get }
    init(isStub: Bool, sampleStatusCode: Int, customEndpointClosure: ((T) -> Endpoint)?)
}

public extension ProviderProtocol {

    static func consProvider(
        _ isStub: Bool = false,
        _ sampleStatusCode: Int = 200,
        _ customEndpointClosure: ((T) -> Endpoint)? = nil) -> MoyaProvider<T> {

        if isStub == false {
            return MoyaProvider<T>(
                endpointClosure: {
                    MoyaProvider<T>.defaultEndpointMapping(for: $0).adding(newHTTPHeaderFields: [:])
                },
                session: Session.default,
                plugins: []// ex - logging, network activity indicator
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
        provider.rx.request(MultiTarget(target))
            .map(type, atKeyPath: keyPath)
            // some operators
    }
    
    func request<D: Decodable>(type: D.Type, atKeyPath keyPath: String? = nil, target: T) -> AnyPublisher<D, MoyaError> {
          provider.requestPublisher(MultiTarget(target))
            .map(type, atKeyPath: keyPath)
            .eraseToAnyPublisher()
            // some operators
    }
}
