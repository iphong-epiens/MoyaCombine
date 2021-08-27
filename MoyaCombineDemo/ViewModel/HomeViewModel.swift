//
//  HomeViewModel.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/08/23.
//

import Foundation
import Combine

class HomeViewModel: BaseViewModel {

  @Published var authSysId: Int = 0
  @Published var userInfoError: Bool = false
  @Published var userInfo: String = ""
  @Published var profileImgUrl: String = ""

  func fetchUserData() {
    guard let authSysId = Utils.shared.authSysId else {
      return
    }

    API.shared.request(ReqAPI.User.getUerInfo(userSysId: authSysId))
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
      }, receiveValue: { response in
        print(response.jsonData.userId)
        print(response.jsonData.name ?? "")
        print(response.jsonData.nickName ?? "")

        self.userInfo = "\(response.jsonData.userId)\n\(response.jsonData.name ?? "")\n\(response.jsonData.nickName ?? "")"
        self.profileImgUrl = response.jsonData.profileImgUrl ?? ""
      })
      .store(in: &cancellables)
  }

  func logOut() {
    do {
      try KeyChain.remove("accessToken")
      try KeyChain.remove("refreshToken")
      try KeyChain.remove("authSysId")
      UserDefaults.standard.set(false, forKey: "isLoggedIn")
    } catch let error {
      print("logOut error: \(error)")
    }
  }
}
