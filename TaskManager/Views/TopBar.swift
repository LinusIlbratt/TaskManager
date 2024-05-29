//
//  TopBar.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-22.
//

import SwiftUI

struct TopBar: View {
    var body: some View {
        HStack {
            Spacer()
            Image("tasktext")
                .resizable()
                .scaledToFit()
                .frame(height: 30)
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.3))
    }
}

#Preview {
    TopBar()
}
