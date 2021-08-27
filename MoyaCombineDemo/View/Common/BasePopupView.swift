//
//  BasePopupView.swift
//  MoyaCombineDemo
//
//  Created by Inpyo Hong on 2021/08/27.
//

import SwiftUI
import ActivityIndicatorView

// https://seons-dev.tistory.com/27

struct BasePopupView: ViewModifier {
  @Binding var draw: Bool
  @Binding var title: String
  @Binding var msg: String
  var cancelable: Bool = false

  func body(content: Content) -> some View {

    content
      .alert(isPresented: $draw) {
        let okButton = Alert.Button.cancel(Text("확인")) {
          print("ok button pressed")
        }

        if cancelable {
          let cancelBtn = Alert.Button.destructive(Text("취소")) {
            print("cancel button pressed")
          }

          return Alert(title: Text(title),
                       message: Text(msg),
                       primaryButton: cancelBtn,
                       secondaryButton: okButton)
        } else {
          return Alert(title: Text(title),
                       message: Text(msg),
                       dismissButton: okButton)
        }
      }
  }
}

extension View {
  func popupView(draw: Binding<Bool>, title: Binding<String> = .constant(""), msg: Binding<String> =  .constant(""), cancelable: Bool = false) -> some View {
    modifier(BasePopupView(draw: draw, title: title, msg: msg, cancelable: cancelable))
  }
}
