//
//  ViewModel.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/08/23.
//

import Foundation
import Combine

class ViewModel: ObservableObject {
  var cancellables = Set<AnyCancellable>()

  @Published var loading = false
  @Published var accessToken: String = "---"
  @Published var refreshToken: String = "---"
  @Published var authSysId: Int = 0
  @Published var userInfoError: Bool = false
  @Published var userInfo: String = ""
  @Published var profileImgUrl: String = ""

  func normalUserLogin(userId: String, password: String) {
    guard let pwdEncodeStr = API.shared.encryptRsaString(password) else { return }

    let authLoginData = LoginReqData(userId: userId, password: pwdEncodeStr)
    let jsonEncodeData = try? Utils.encoder.encode(authLoginData)
    guard let jsonData = jsonEncodeData, let jsonString = String(data: jsonData, encoding: .utf8) else { return }

    self.loading = true

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
        DispatchQueue.main.async {
          self.loading = false
        }
      }, receiveValue: { response in
        print(response)
        do {
          self.accessToken = response.jsonData.accessToken
          self.refreshToken = response.jsonData.refreshToken
          self.authSysId = response.jsonData.authSysId

          try KeyChain.set(response.jsonData.accessToken, key: "accessToken")
          try KeyChain.set(response.jsonData.refreshToken, key: "refreshToken")
        } catch let error {
          print(error.localizedDescription)
        }
      })
      .store(in: &cancellables)
  }

  func fetchUserData() {
    guard let accessToken = Utils.shared.accessToken, self.authSysId > 0 else {
      return
    }

    guard self.authSysId > 0 else {
      self.userInfoError = true
      return
    }

    self.loading = true

    API.shared.request(ReqAPI.User.getUerInfo(accessToken: accessToken, userSysId: self.authSysId))
      .map { $0.data }
      .decode(type: UserInfoRespData.self, decoder: JSONDecoder())
      .sink(receiveCompletion: { completion in
        print(completion)
        switch completion {
        case .failure(let error):
          print(error.localizedDescription)

        default:
          break
        }
        DispatchQueue.main.async {
          self.loading = false
        }
      }, receiveValue: { response in
        print(response.jsonData.userId)
        print(response.jsonData.name ?? "")
        print(response.jsonData.nickName ?? "")

        self.userInfo = "\(response.jsonData.userId)\n\(response.jsonData.name ?? "")\n\(response.jsonData.nickName ?? "")"
        self.profileImgUrl = response.jsonData.profileImgUrl ?? ""
      })
      .store(in: &cancellables)
  }
}
