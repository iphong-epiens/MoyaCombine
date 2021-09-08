//
//  LogInView.swift
//  AppStorage
//
//  Created by Inpyo Hong on 2021/08/24.
//

import SwiftUI
import ActivityIndicatorView
import SPAlert

struct LogInView: View {
  @StateObject var viewModel = LogInViewModel()
  @EnvironmentObject private var settings: AppSettings
  @AppStorage("isLoggedIn") var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")

  var body: some View {
    BaseView {
      Button(action: {
        self.viewModel.normalUserLogin(userId: "y2kpaulh@epiens.com", password: "test123")
      }) {
        Text("로그인")
      }

      if viewModel.userInfoError {
        LoggerView("userInfoError")
      }

      ActivityIndicatorView(isVisible: $viewModel.networkLoading, type: .gradient([Color.gray, Color.black]))
        .frame(width: 100, height: 100)
        .foregroundColor(.black)
    }
    .popupView(draw: $viewModel.networkPopup, title: $viewModel.networkMsg)
  }
}

struct LogInView_Previews: PreviewProvider {
  static var previews: some View {
    LogInView()
  }
}
