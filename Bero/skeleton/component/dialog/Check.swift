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
    func check(isShowing: Binding<Bool>, text: String, isAuto:Bool, action: (() -> Void)? = nil) -> some View {
        Check(isShowing: isShowing,
              presenting: { self },
              text: text,
              isAuto: isAuto,
              action: action
        )
    }
    
}

struct Check<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    var text: String
    var isAuto: Bool
    var duration:Double = 1.5
    var action: (() -> Void)? = nil
    @State var safeAreaBottom:CGFloat = 0
    @State var isChecked = false
    var body: some View {
        ZStack(alignment: .center) {
            self.presenting().opacity(self.isShowing ? 1 : 0)
            VStack(spacing:Dimen.margin.regularExtra){
                if self.isAuto {
                    Image(Asset.icon.checked_circle)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.brand.primary)
                        .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
                } else {
                    ImageButton(
                        isSelected: self.isChecked,
                        defaultImage: Asset.icon.checked_circle,
                        size: CGSize(width: Dimen.icon.heavy, height: Dimen.icon.heavy),
                        defaultColor: Color.app.grey400,
                        activeColor: Color.brand.primary
                    ){_ in
                        withAnimation{self.isChecked = true}
                        self.action?()
                        DispatchQueue.main.asyncAfter(deadline:.now()+0.2){
                            withAnimation {self.isShowing = false}
                            self.isChecked = false
                        }
                    }
                }
                Text(self.text)
                    .modifier(MediumTextStyle(size: Font.size.thin, color: Color.brand.primary))
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, Dimen.margin.regularUltra)
            .padding(.horizontal, Dimen.margin.light)
            .frame(width: 208)
            .background(Color.app.orangeSub)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
            .overlay(
                RoundedRectangle(cornerRadius:Dimen.radius.tiny)
                    .strokeBorder(
                        Color.brand.primary.opacity(0.3),
                        lineWidth: Dimen.stroke.light
                    )
            )
            .padding(.bottom, self.safeAreaBottom)
            .offset(y:self.isShowing ? 0 : 100)
            .opacity(self.isShowing ? 1 : 0)
        }
        
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
        .onReceive( [self.isShowing].publisher ) { show in
            DataLog.d("Check")
            if !self.isAuto {return}
            if !show  { return }
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + self.duration) {
                DispatchQueue.main.async {
                    withAnimation {self.isShowing = false}
                }
            }
        }
    }
}
