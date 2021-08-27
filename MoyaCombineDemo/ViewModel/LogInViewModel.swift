//
//  LogInViewModel.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/08/23.
//

import Foundation
import Combine

class LogInViewModel: BaseViewModel {
  @Published var userInfoError: Bool = false
  @Published var userInfo: String = ""
  @Published var profileImgUrl: String = ""

  func normalUserLogin(userId: String, password: String) {
    guard let pwdEncodeStr = API.shared.encryptRsaString(password) else { return }

    let authLoginData = LoginReqData(userId: userId, password: pwdEncodeStr)
    let jsonEncodeData = try? Utils.encoder.encode(authLoginData)
    guard let jsonData = jsonEncodeData, let jsonString = String(data: jsonData, encoding: .utf8) else { return }

    API.shared.request(ReqAPI.Auth.login(jsonString.toParams))
      .map { $0.data }
      .decode(type: LoginRespData.self, decoder: JSONDecoder())
      .sink(receiveCompletion: { completion in
        print(completion)
        switch completion {
        case .failure(let error):
          print(error.localizedDescription)

        default:
          break
        }
      }, receiveValue: { response in
        print(response)

        do {
          try KeyChain.set(response.jsonData.accessToken, key: "accessToken")
          try KeyChain.set(response.jsonData.refreshToken, key: "refreshToken")
          try KeyChain.set("\(response.jsonData.authSysId)", key: "authSysId")

          UserDefaults.standard.setValue(true, forKey: "isLoggedIn")

          //로그인 후 퍼블릭 키 갱신
          API.shared.getPublicKey()

        } catch let error {
          print(error.localizedDescription)
        }

      })
      .store(in: &cancellables)
  }
}
