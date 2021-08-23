//
//  String+Extension.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/02/27.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation

extension String {
  var compacted: String {
    return components(separatedBy: .whitespaces).joined()
  }

  var trimmed: String {
    return trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func separate(every stride: Int = 4, with separator: Character = " ") -> String {
    return String(enumerated()
                    .map({ $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]})
                    .joined())
  }
}

extension String {
  enum ValidationType {
    case name
    case address

    var regex: String {
      switch self {
      case .name: return "^.{1,100}$"
      case .address: return "(.*[0-9a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ-.,()\\[\\]{}])"
      }
    }
  }

  func validate(type: ValidationType) -> Bool {
    var emojiPatterns = [UnicodeScalar(0x1F300)!...UnicodeScalar(0x1F5FF)!]
    emojiPatterns.append(contentsOf: [UnicodeScalar(0x1F600)!...UnicodeScalar(0x1F64F)!])
    emojiPatterns.append(contentsOf: [UnicodeScalar(0x1F680)!...UnicodeScalar(0x1F6FF)!])
    emojiPatterns.append(contentsOf: [UnicodeScalar(0x1F1E6)!...UnicodeScalar(0x1F1FC)!])
    emojiPatterns.append(contentsOf: [UnicodeScalar(0x1F900)!...UnicodeScalar(0x1F9FF)!])
    emojiPatterns.append(contentsOf: [UnicodeScalar(0x2600)!...UnicodeScalar(0x26FF)!])
    emojiPatterns.append(contentsOf: [UnicodeScalar(0x2700)!...UnicodeScalar(0x27BF)!])

    let isIncludeEmoji = self.unicodeScalars
      .filter { ucScalar in emojiPatterns.contains { $0 ~= ucScalar } }.count > 0

    switch type {
    case .name:
      return NSPredicate(format: "SELF MATCHES %@", type.regex).evaluate(with: self)

    case .address:
      return !isIncludeEmoji && NSPredicate(format: "SELF MATCHES %@", type.regex).evaluate(with: self)
    }
  }
}

extension String {
  var toParams: [String: Any] {
    return ["jsonData": self]
  }
}

private extension String {
  var URLEscapedString: String {
    return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
  }
}
