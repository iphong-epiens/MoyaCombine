//
//  MoyaCombineApp.swift
//  MoyaCombine
//
//  Created by Inpyo Hong on 2021/08/13.
//

import SwiftUI

@main
struct MoyaCombineApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
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
