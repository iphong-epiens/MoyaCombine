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
        case .finished:
          print("finished")

        case .failure(let error):
          print(error.localizedDescription)
        }
      }, receiveValue: { response in
        print(response)
        do {
          try KeyChain.set(response.jsonData.refreshToken, key: "refreshToken")
          try KeyChain.set(response.jsonData.accessToken, key: "accessToken")
        } catch let error {
          print(error.localizedDescription)
        }
      })
      .store(in: &cancellables)
  }
}
