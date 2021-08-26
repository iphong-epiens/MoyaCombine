//
//  HomeViewModel.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/08/23.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
  var cancellables = Set<AnyCancellable>()

  @Published var authSysId: Int = 0
  @Published var userInfoError: Bool = false
  @Published var userInfo: String = ""
  @Published var profileImgUrl: String = ""
  @Published var networkPopup: Bool = false
  @Published var networkMsg: String = ""
  @Published var networkLoading: Bool = false

  init() {
    NotificationCenter.default.publisher(for: NetworkInfoNotificationSender.notification)
      .compactMap {$0.object as? NetworkInfoNotificationSender}
      .map {$0.message}
      .receive(on: DispatchQueue.main)
      .sink {
        self.networkPopup = true
        self.networkMsg = $0
      }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: NetworkLoadingNotificationSender.notification)
      .compactMap {$0.object as? NetworkLoadingNotificationSender}
      .map {$0.loading}
      .receive(on: DispatchQueue.main)
      .sink {
        print("networkLoading", self.networkLoading)
        self.networkLoading = $0
      }
      .store(in: &cancellables)
  }

  func fetchUserData() {
    guard let accessToken = Utils.shared.accessToken, let authSysId = Utils.shared.authSysId else {
      return
    }

    API.shared.request(ReqAPI.User.getUerInfo(accessToken: accessToken, userSysId: authSysId))
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
