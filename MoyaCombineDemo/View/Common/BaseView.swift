//
//  BaseView.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/08/27.
//

import SwiftUI

struct BaseView<T: View>: View {
  var bgColor: Color
  let content: T
  init(@ViewBuilder content: () -> T, bgColor: Color = .white) {
    self.content = content()
    self.bgColor = bgColor
  }

  var body: some View {
    ZStack {
      self.bgColor.ignoresSafeArea()
      content
    }
  }
}

struct BaseView_Previews: PreviewProvider {
  static var previews: some View {
    BaseView(content: {
      VStack {
        Text("baseview")
        Text("baseview")
          .foregroundColor(.white)
      }
    }, bgColor: .yellow)
  }
}
