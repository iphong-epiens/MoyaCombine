//
//  MoyaCombineApp.swift
//  MoyaCombine
//
//  Created by Inpyo Hong on 2021/08/13.
//

import SwiftUI
import Combine
import KeychainAccess

let KeyChain = MoyaCombineApp.keychain

@main
struct MoyaCombineApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @Environment(\.scenePhase) private var scenePhase
  @StateObject var settings: AppSettings = AppSettings()
  static let keychain = Keychain(service: Bundle.main.bundleIdentifier!).accessibility(.afterFirstUnlock)

  init() {

  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(settings)
        .onAppear {
          //                    print(FileManager.documentURL ?? "")
          //                    for fontFamily in UIFont.familyNames {
          //                        for fontName in UIFont.fontNames(forFamilyName: fontFamily) {
          //                            print(fontName)
          //                        }
          //                    }
        }
        .onOpenURL { url in
          // call my-deeplink-test://share?id=1234
          if url.scheme == "my-deeplink-test" && url.host == "share" {
            if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) {
              for query in components.queryItems! {
                print(query.name)
                print(query.value!)
              }
            }
          }
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
