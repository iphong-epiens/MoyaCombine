//
//  LoggerView.swift
//  Meal
//
//  Created by Inpyo Hong on 2021/09/08.
//

import SwiftUI

// reference: https://www.lukecsmith.co.uk/2020/05/27/quick-tip-logging-within-swiftui/

func LoggerView(_ log: String) -> EmptyView {
  #if DEBUG
  var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

    return dateFormatter
  }

  print(">>> LoggerView: \(dateFormatter.string(from: Date())) \(log)")
  #endif

  return EmptyView()
}
