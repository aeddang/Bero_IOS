//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import GoogleMaps



struct ChatBox: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var dataProvider:DataProvider
    @State var input = ""
    @State var isFocus:Bool = false
    @State var paddingBottom:CGFloat = 0
    @State var sendUser:String = ""
    var body: some View {
        VStack(spacing:0){
            Spacer().modifier(MatchParent()).background(Color.transparent.clearUi)
                .onTapGesture {
                    withAnimation{self.isFocus = false}
                    AppUtil.hideKeyboard()
                }
            ZStack(alignment: .top){
                InputComment(
                    input: self.$input,
                    isFocus: self.isFocus,
                    onFocus: {
                        withAnimation{self.isFocus = true}
                    },
                    onAction: {
                        self.sendMessage()
                    }
                )
            }
            .padding(.horizontal, Dimen.app.pageHorinzontal)
            .modifier(MatchHorizontal(height: 60))
            .background(Color.app.white)
        }
        .padding(.bottom, self.paddingBottom)
        .opacity(self.isFocus ? 1 : 0)
        .onReceive (self.sceneObserver.$safeAreaBottom) { bottom in
            withAnimation{
                self.paddingBottom = bottom
            }
        }
        .onReceive (self.appSceneObserver.$event) { evt in
            guard let evt = evt else {return}
            switch evt {
            case .sendChat(let userId) :
                self.sendUser = userId
                self.isFocus  = true
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .sendChat:
                withAnimation{self.isFocus = false}
                AppUtil.hideKeyboard()
            default : break
            }
        }
    }
    
    private func sendMessage(){
        if self.input.isEmpty { return }
        self.dataProvider.requestData(q: .init(id: self.tag, type: .sendChat(userId: self.sendUser, contents: self.input)))
    }
    
}


