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
        Text("userInfoError")
      }

      ActivityIndicatorView(isVisible: $viewModel.networkLoading, type: .gradient([Color.gray, Color.black]))
        .frame(width: 100, height: 100)
        .foregroundColor(.black)
    }
    //    .spAlert(isPresent: $viewModel.networkPopup,
    //             title: "Alert title",
    //             message: "Alert message",
    //             duration: 2.0,
    //             dismissOnTap: false,
    //             preset: .custom(UIImage(systemName: "heart")!),
    //             haptic: .success,
    //             layout: .init(),
    //             completion: {
    //              print("Alert is destory")
    //             })

    // https://seons-dev.tistory.com/27
    .alert(isPresented: $viewModel.networkPopup) {
      Alert(title: Text("Title"),
            message: Text(viewModel.networkMsg),
            dismissButton: .default(Text("OK")))
    }
  }
}

struct LogInView_Previews: PreviewProvider {
  static var previews: some View {
    LogInView()
  }
}
