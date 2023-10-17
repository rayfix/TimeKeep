//
//  SelectAllText.swift
//  TimeKeep
//
//  Created by Ray Fix on 10/14/23.
//

import SwiftUI
import UIKit

public struct SelectAllTextOnBeginEditingModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .onReceive(NotificationCenter.default.publisher(
        for: UITextField.textDidBeginEditingNotification)) { _ in
          DispatchQueue.main.async {
            UIApplication.shared.sendAction(
              #selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil
            )
          }
        }
  }
}

extension View {
    public func selectAllTextOnBeginEditing() -> some View {
        modifier(SelectAllTextOnBeginEditingModifier())
    }
}


