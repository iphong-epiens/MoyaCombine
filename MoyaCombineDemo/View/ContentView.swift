//
//  ContentView.swift
//  MoyaCombine
//
//  Created by Inpyo Hong on 2021/08/13.
//

import SwiftUI
import Combine
import CombineMoya
import Moya
import KeychainAccess
import CryptoSwift
import JWTDecode
import SwiftyRSA
import Kingfisher
import ActivityIndicatorView
import SPAlert

struct ContentView: View {
  @StateObject var viewModel = ViewModel()
  @EnvironmentObject private var settings: AppSettings

  init() {
    SPAlertConfiguration.duration = 2
    SPAlertConfiguration.cornerRadius = 12
  }

  var body: some View {
    ZStack {
      Color.gray.ignoresSafeArea()

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
              .resizable()
              .frame(width: 100, height: 100, alignment: .center)
              .cornerRadius(100/2)
              .shadow(radius: 10)
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

    }.onAppear {
      //print(">>> settings.appList", settings.appList)
      self.viewModel.normalUserLogin(userId: "y2kpaulh@epiens.com", password: "test123")
    }
    .spAlert(isPresent: $viewModel.networkPopup,
             title: "Alert title",
             message: "Alert message",
             duration: 2.0,
             dismissOnTap: false,
             preset: .custom(UIImage(systemName: "heart")!),
             haptic: .success,
             layout: .init(),
             completion: {
              print("Alert is destory")
             })
    //    // https://seons-dev.tistory.com/27
    //    .alert(isPresented: $viewModel.networkPopup) {
    //      Alert(title: Text("Title"),
    //            message: Text("Message"),
    //            dismissButton: .default(Text("OK")))
    //    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
