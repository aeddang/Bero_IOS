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
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var dataProvider:DataProvider
    @Binding var isActive:Bool
    @State var input = ""
    @State var isFocus:Bool = false
    @State var isShow:Bool = false
    @State var paddingBottom:CGFloat = 0
    @State var sendUser:String = ""
    var body: some View {
        ZStack(alignment: .bottom){
            Spacer().modifier(MatchParent())
                .background(self.isFocus ? Color.transparent.clearUi : Color.transparent.clear)
                .onTapGesture {
                    self.sendMessageCompleted()
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
            .background(Color.app.white)
        }
        .padding(.bottom, self.paddingBottom)
        .opacity(self.isShow ? 1 : 0)
        .onReceive (self.sceneObserver.$safeAreaBottom) { bottom in
            withAnimation{
                self.paddingBottom = bottom
            }
        }
        .onReceive (self.appSceneObserver.$event) { evt in
            guard let evt = evt else {return}
            switch evt {
            case .setupChat(let userId, let isFocus, let isActive) :
                self.input = ""
                withAnimation{self.isActive = isActive}

                if isActive {
                    self.sendUser = userId
                    self.isFocus  = isFocus
                } else {
                    self.sendUser = ""
                    self.isFocus = false
                    AppUtil.hideKeyboard()
                }
                withAnimation{self.isShow = isActive}
                
            case .sendChat(let userId) :
                self.input = ""
                self.sendUser = userId
                self.isFocus  = true
                withAnimation{self.isActive = false}
                withAnimation{self.isShow = true}
                if self.repository.storage.isFirstChat {
                    self.repository.storage.isFirstChat = false
                    self.appSceneObserver.alert = .alert(nil, String.alert.firstChatMessage)
                }
                
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .sendChat:
                self.input = ""
                self.sendMessageCompleted()
            default : break
            }
        }
    }
    
    private func sendMessage(){
        if self.input.isEmpty { return }
        self.dataProvider.requestData(q: .init(id: self.tag, type: .sendChat(userId: self.sendUser, contents: self.input)))
    }
    
    private func sendMessageCompleted(){
        
        self.isFocus = false
        AppUtil.hideKeyboard()
        if !self.isActive {
            withAnimation{self.isShow = false}
        }
    }
}


