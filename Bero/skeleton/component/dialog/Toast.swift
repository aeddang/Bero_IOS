//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

extension View {
    func toast(isShowing: Binding<Bool>, text: String) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
    
}

struct Toast<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    var text: String
    var duration:Double = 1.5
    @State var safeAreaBottom:CGFloat = 0
    var body: some View {
        ZStack(alignment: .bottom) {
            self.presenting()
            Text(self.text)
                .modifier(MediumTextStyle(size: Font.size.thin, color: Color.brand.primary))
            .padding(.all, Dimen.margin.light)
            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/,  maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
            .background(Color.app.white)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
            .overlay(
                RoundedRectangle(cornerRadius:Dimen.radius.tiny)
                    .strokeBorder(
                        Color.brand.primary,
                        lineWidth: Dimen.stroke.light
                    )
            )
            .padding(.bottom, self.safeAreaBottom)
            .padding(.horizontal, Dimen.margin.regular)
            .offset(y:self.isShowing ? 0 : 100)
            .opacity(self.isShowing ? 1 : 0)
        }
       
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
        .onReceive( [self.isShowing].publisher ) { show in
            DataLog.d("Toast")
            if !show  {
                self.cancelAutoHidden()
                return
            }
            if self.autoHidden == nil {
                self.delayAutoHidden()
            }
        }
        
    }
    @State var autoHidden:AnyCancellable?
    func delayAutoHidden(){
        self.autoHidden?.cancel()
        self.autoHidden = Timer.publish(
            every: self.duration, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.autoHidden?.cancel()
                withAnimation {
                   self.isShowing = false
                }
            }
    }
    func cancelAutoHidden(){
        self.autoHidden?.cancel()
        self.autoHidden = nil
    }
}
