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

    sut.requestDebug(ReqAPI.Auth.publickey(), type: PublicKeyResultData.self, atKeyPath: "jsonData")
      .map { $0.res.publicKey }
      .sink(receiveCompletion: { completion in
        print(">>> completion", completion)
      }, receiveValue: { response in
        print(">>> response", response)
        XCTAssertEqual(response, "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA27Bf/sFXPg8cXgLp/n3tqTfKIZ/lcxO3I4K0NfXTXNm49KDmUofzntTS8bPvgcX688ZJRYDwig6a5ZmFE8FFSCdqJuUQ1c9UjnlU4KA7ztHDdPgd+zxCn9+lfaYgDXvwjXQb0t53u001VX5s/eTxsFri9qvMmdDQT4McYN1nIAUsDBDxPAkBQy4+CEddqWCjPLptqdroEUIgQ6fxrVVVzhuIpiG9zcSr/1RLbw6YERBxbVk/Q/CrgC5fKXWYRI5T4+V9MX4BxVvpqR2B+KEfxYQsXvJ2nyV0tKtb+m2hu+HtE4onsoM/lbm0Hw6yMKp/P2MofIyFNTdWeBcyEI3aRwIDAQAB")
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
