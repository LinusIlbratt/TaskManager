//
//  ButtonStyleModifier.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-06-10.
//

import SwiftUI

struct ButtonStyleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: 5)
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.5))
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 1)
                }
            )
    }
}

extension View {
    func buttonStyle() -> some View {
        self.modifier(ButtonStyleModifier())
    }
}

