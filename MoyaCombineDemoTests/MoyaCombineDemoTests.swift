//
//  MoyaCombineDemoTests.swift
//  MoyaCombineDemoTests
//
//  Created by Inpyo Hong on 2021/09/02.
//

import XCTest
import RxMoya
import RxSwift
import Combine
import Moya

@testable import MoyaCombineDemo

class MoyaCombineDemoTests: XCTestCase {
  var sut: NetworkManager!
  var cancellables = Set<AnyCancellable>()

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    sut = NetworkManager(isStub: true)
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testFetchPublicKey() {
    let expectation = XCTestExpectation()

    guard let sampleData = try? JSONDecoder().decode(PublicKeyResultData.self, from: ReqAPI.Auth.publickey().sampleData) else {
      return
    }

    sut.requestDebug(ReqAPI.Auth.publickey(), type: PublicKeyResultData.self, atKeyPath: "jsonData")
      .map { $0.res.publicKey }
      .sink(receiveCompletion: { completion in
        print(">>> completion", completion)
      }, receiveValue: { response in
        print(">>> response", response)
        XCTAssertEqual(response, sampleData.res.publicKey)
        expectation.fulfill()
      })
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 2.0)
  }

  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    measure {
      // Put the code you want to measure the time of here.
    }
  }

}
