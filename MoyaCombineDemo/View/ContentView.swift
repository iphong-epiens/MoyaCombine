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
    .alert(isPresented: $viewModel.networkPopup) {
      Alert(title: Text("Title"),
            message: Text(viewModel.networkMsg),
            dismissButton: .default(Text("OK")))
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
