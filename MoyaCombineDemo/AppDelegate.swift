//
//  AppDelegate.swift
//  Meal
//
//  Created by Inpyo Hong on 2021/08/09.
//

import Foundation
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    print(#function)
    return true
  }

  func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
    print(#function)
  }
}
