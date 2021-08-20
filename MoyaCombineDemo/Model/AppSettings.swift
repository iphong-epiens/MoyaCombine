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
    @Published var appList = ["aaa"]
    static let keychain = Keychain(service: Bundle.main.bundleIdentifier!).accessibility(.afterFirstUnlock)
}
