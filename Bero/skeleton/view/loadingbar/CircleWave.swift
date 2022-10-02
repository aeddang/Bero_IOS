//
//  CircleWave.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/07/29.
//

import Foundation
import SwiftUI

struct CircleWave: View {
    @State private var shouldAnimate = false
    var color:Color = Color.brand.primary
    var body: some View {
        Circle()
            .fill(Color.transparent.clear)
            .frame(width: 30, height: 30)
            .overlay(
                ZStack {
                    Circle()
                        .stroke(self.color, lineWidth: 100)
                        .scaleEffect(shouldAnimate ? 1 : 0)
                    Circle()
                        .stroke(self.color, lineWidth: 100)
                        .scaleEffect(shouldAnimate ? 1.5 : 0)
                    Circle()
                        .stroke(self.color, lineWidth: 100)
                        .scaleEffect(shouldAnimate ? 2 : 0)
                }
                .opacity(shouldAnimate ? 0.0 : 0.2)
                .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false))
        )
        .onAppear {
            self.shouldAnimate = true
        }
    }
    
}
