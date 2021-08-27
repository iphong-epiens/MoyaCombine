//
//  BaseViewModel.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/08/27.
//

import Foundation
import Combine

class BaseViewModel: ObservableObject {
  var cancellables = Set<AnyCancellable>()

  @Published var networkPopup: Bool = false
  @Published var networkMsg: String = ""
  @Published var networkLoading: Bool = false

  init() {
    NotificationCenter.default.publisher(for: NetworkInfoNotificationSender.notification)
      .compactMap {$0.object as? NetworkInfoNotificationSender}
      .map {$0.message}
      .receive(on: DispatchQueue.main)
      .sink {
        self.networkPopup = true
        self.networkMsg = $0
      }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: NetworkLoadingNotificationSender.notification)
      .compactMap {$0.object as? NetworkLoadingNotificationSender}
      .map {$0.loading}
      .receive(on: DispatchQueue.main)
      .sink {
        print("networkLoading", self.networkLoading)
        self.networkLoading = $0
      }
      .store(in: &cancellables)
  }
}
