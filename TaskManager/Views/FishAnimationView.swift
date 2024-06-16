//
//  fishAnimationView.swift
//  TaskManager
//
//  Created by Mattias Axelsson on 2024-05-31.
//

import SwiftUI

struct FishAnimationView: View {
    @Binding var animationTrigger: Bool
    var startPosition: CGPoint
    var endPosition: CGPoint
    
    var body: some View {
        Image(systemName: "fish.fill")
            .foregroundColor(.black)
            .offset(x: animationTrigger ? endPosition.x - startPosition.x : 0, y: animationTrigger ? endPosition.y - startPosition.y : 0)
            .animation(Animation.linear(duration: 1).delay(Double.random(in: 0...0.5)), value: animationTrigger)
    }
}

struct FishAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        FishAnimationView(animationTrigger: .constant(true), startPosition: CGPoint(x: 0, y: 0), endPosition: CGPoint(x: 100, y: 100))
    }
}

