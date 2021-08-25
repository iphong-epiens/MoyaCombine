//
//  AppSettings.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/08/20.
//

import Foundation
import Combine
import KeychainAccess

class AppSettings: ObservableObject {
  var isLoggedIn: Bool {
    get {
      UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    set {
      UserDefaults.standard.setValue(newValue, forKey: "isLoggedIn")
    }
  }
}
