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

struct ContentView: View {
  @StateObject var viewModel = ViewModel()
  @EnvironmentObject private var settings: AppSettings

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

      if viewModel.loading {
        ActivityIndicator()
      }

      if viewModel.userInfoError {
        Text("userInfoError")
      }

      if viewModel.networkPopup {
        Text("\(viewModel.networkMsg)")
      }

    }.onAppear {
      //print(">>> settings.appList", settings.appList)
      self.viewModel.normalUserLogin(userId: "y2kpaulh@epiens.com", password: "test123")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
