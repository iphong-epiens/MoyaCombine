//
//  ContentView.swift
//  MoyaCombine
//
//  Created by Inpyo Hong on 2021/08/13.
//

import SwiftUI
import ActivityIndicatorView

struct ContentView: View {
  @StateObject var viewModel = ContentViewModel()
  @EnvironmentObject private var settings: AppSettings
  @AppStorage("isLoggedIn") var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")

  init() {
    configRefreshToken()
  }

  var body: some View {
    BaseView {
      if isLoggedIn {
        HomeView()
      } else {
        LogInView()
      }

      ActivityIndicatorView(isVisible: $viewModel.networkLoading, type: .gradient([Color.gray, Color.black]))
        .frame(width: 100, height: 100)
        .foregroundColor(.black)
    }
    .popupView(draw: $viewModel.networkPopup, title: $viewModel.networkMsg)
  }

  func configRefreshToken() {
    //update refresh token
    guard UserDefaults.standard.bool(forKey: "isLoggedIn") == true,
          let refreshToken = try? KeyChain.getString("refreshToken"),
          !API.shared.tokenIsValid else { return }

    API.shared.updateRefreshToken(refreshToken)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
