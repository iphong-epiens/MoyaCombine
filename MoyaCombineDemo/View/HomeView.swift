//
//  HomeView.swift
//  AppStorage
//
//  Created by Inpyo Hong on 2021/08/24.
//

import SwiftUI
import Kingfisher
import ActivityIndicatorView
import SPAlert

struct HomeView: View {
  @StateObject var viewModel = HomeViewModel()
  @EnvironmentObject private var settings: AppSettings
  @AppStorage("isLoggedIn") var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")

  init() {
    SPAlertConfiguration.duration = 2
    SPAlertConfiguration.cornerRadius = 12
  }

  var body: some View {
    BaseView {
      VStack(spacing: 20) {
        Button("회원 정보") {
          viewModel.fetchUserData()
        }
        .foregroundColor(.black)
        .font(.largeTitle)

        HStack {
          if viewModel.userInfo.count > 0 {
            Text(viewModel.userInfo)
              .fontWeight(.bold)
          }

          if viewModel.profileImgUrl.count > 0 {
            KFImage(URL(string: viewModel.profileImgUrl)!)
              .retry(maxCount: 2)
              .onSuccess { result in
                print("profileImgUrl success: \(result)")
              }
              .onFailure { error in
                print("profileImgUrl failure: \(error.localizedDescription)")
              }
              .resizable()
              .frame(width: 100, height: 100, alignment: .center)
              .cornerRadius(100/2)
              .shadow(radius: 10)
          }
        }

        Spacer()

        if settings.isLoggedIn {
          Button(action: {
            viewModel.logOut()
          }) {
            Text("로그아웃")
          }
        }

        Spacer()
      }.padding()

      if viewModel.userInfoError {
        Text("userInfoError")
      }

      ActivityIndicatorView(isVisible: $viewModel.networkLoading, type: .gradient([Color.gray, Color.black]))
        .frame(width: 100, height: 100)
        .foregroundColor(.black)
    }
    .onAppear {
      self.viewModel.fetchUserData()
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
    .popupView(draw: $viewModel.networkPopup, title: $viewModel.networkMsg)
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
