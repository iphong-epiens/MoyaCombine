//
//  MoyaCombineApp.swift
//  MoyaCombine
//
//  Created by Inpyo Hong on 2021/08/13.
//

import SwiftUI
import Combine
import KeychainAccess
import CryptoSwift
import SwiftyRSA


@main
struct MoyaCombineApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var settings: AppSettings = AppSettings()
  //  static let keychain = Keychain(service: Bundle.main.bundleIdentifier!).accessibility(.afterFirstUnlock)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .onAppear{
//                    print(FileManager.documentURL ?? "")
//                    for fontFamily in UIFont.familyNames {
//                        for fontName in UIFont.fontNames(forFamilyName: fontFamily) {
//                            print(fontName)
//                        }
//                    }
                }
                .onOpenURL { _ in // URL handling

                }
                .onChange(of: scenePhase) { phase in
                  // change in this app's phase - composite of all scenes
                  switch phase {
                  case .active:
                    //changedToActive()
                    print("active")

                  case .background:
                    //changedToBackground()
                    print("background")

                  case .inactive:
                    //changedToInactive()
                    print("inactive")

                  default:
                    break
                  }
                }
        }
    }
}
