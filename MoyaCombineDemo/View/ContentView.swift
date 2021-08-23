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

struct ContentView: View {
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject private var settings: AppSettings

  var body: some View {
    ZStack {

    }.onAppear {
      print(">>> settings.appList", settings.appList)
      self.viewModel.normalUserLogin(userId: "y2kpaulh@epiens.com", password: "test123")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
