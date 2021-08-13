//
//  FileManagerExtensions.swift
//  Meal
//
//  Created by Inpyo Hong on 2021/07/09.
//

import Foundation

extension FileManager {
  static var documentURL: URL? {
    return Self.default.urls(
      for: .documentDirectory,
      in: .userDomainMask).first
  }
}
