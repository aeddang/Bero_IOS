//
//  PageContentBody.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/20.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
struct PageBackgroundBody: View {
    @EnvironmentObject var pageChanger:PagePresenter
    var body: some View {
        ZStack{
            Rectangle().fill(pageChanger.bodyColor)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

extension PageContentBody{
    static let pageMoveDuration:CGFloat = 0.2
    static let pageMoveAmount:CGFloat = -70.0
    private static var useBelowPageMove:Bool {
        get{
            if #available(iOS 14.0, *) { return true }
            else { return false }
        }
    }
}

struct PageContentBody: PageView  {
    var childView:PageViewProtocol? = nil
    @EnvironmentObject var pageChanger:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State var offsetX:CGFloat = 0
    @State var offsetY:CGFloat = 0
    @State var dragOpacity:Double = 0.0
    @State var opacity:Double = 1.0
    @State var pageOffsetX:CGFloat = 0.0
    @State var pageOffsetY:CGFloat = 0.0
    @State var isTop:Bool = true
    @State var isBelow:Bool = false
    @State var topPageType:PageAnimationType = .none
    @State var isReady:Bool = false
    @State var isVoiceOver:Bool = true
    let useBelowPageMove = Self.useBelowPageMove
    var body: some View {
        ZStack(){
            if let child = childView {
                child.contentBody
                    .offset(x: self.offsetX ,y: self.offsetY)
                    .offset(x:  self.pageOffsetX, y:  -self.pageOffsetY )
            }
            Spacer().modifier(MatchParent()).background(Color.transparent.black70)
                .opacity(self.dragOpacity)
                .opacity(self.isBelow ? 1 : 0)
        }
        .opacity(self.opacity)
        .accessibilityElement(children: self.isVoiceOver ? .contain : .ignore)
        .onReceive(self.pageChanger.$currentTopPage){ page in
            guard let page = page else { return }
            if !self.isReady  {return}
            guard let pageObject = self.pageObject else { return }
            self.topPageType = page.animationType
            if pageObject == page {
                self.isVoiceOver = UIAccessibility.isVoiceOverRunning
                
            } else {
                self.isVoiceOver = false
            }
            if pageObject.isLayer || pageObject.isWillCloseLayer{
                self.dragOpacity = 0
                return
            }
            if PageObject.isSamePage(l:pageObject , r:page) {
                withAnimation(.easeIn(duration: Self.pageMoveDuration)){
                    self.isTop = true
                    self.isBelow = false
                    self.pageOffsetX = 0.0
                    self.pageOffsetY = 0.0
                }
            }
        }
        .onReceive(self.sceneObserver.$event){ evt in
            guard let evt  = evt else {return}
            switch evt {
            case .changed :
                //if self.isTop {return}
                guard let page = self.pageChanger.currentTopPage else { return }
                guard let pageObject = self.pageObject else { return }
                if pageObject.isLayer { return }
                if pageObject.animationType == .opacity { return }
                if pageObject.animationType == .reverseVertical { return }
                if pageObject.animationType == .reverseHorizontal { return }
                if self.offsetX != 0 || self.offsetY != 0 { return }
                let below = self.pageChanger.getBelowPage(page: page)
                if  UIAccessibility.isVoiceOverRunning {
                    self.isTop = false
                    self.isBelow = PageObject.isSamePage(l: below , r: pageObject)
                    self.dragOpacity = 1
                    if !self.useBelowPageMove {return}
                    switch self.topPageType {
                    case .horizontal :
                        self.pageOffsetX = self.sceneObserver.screenSize.width
                        self.pageOffsetY = 0
                    
                    case .vertical :
                        self.pageOffsetY = -self.sceneObserver.screenSize.height
                        self.pageOffsetX = 0
                    
                    default : break
                    }
                } else {
                    let needAni = PageObject.isSamePage(l: below , r: pageObject)
                    if needAni {
                        withAnimation(.easeOut(duration: Self.pageMoveDuration)){
                            self.bellowAnimation(isBelow: true)
                        }
                    } else if !self.isTop {
                        self.bellowAnimation(isBelow: false)
                    }
                }
            }
        }
        .onReceive(self.pageChanger.$dragOpercity){ opacity in
            if !self.isReady  {return}
            if !self.isBelow {return}
            if self.isTop {return}
            self.dragOpacity = opacity
            if !self.useBelowPageMove {return}
            let amount = Self.pageMoveAmount * CGFloat(opacity)
            switch self.topPageType {
            case .horizontal :  self.pageOffsetX = amount
            case .vertical :  self.pageOffsetY = -amount
            default :break
            }
        }
        .onReceive(self.pageObservable.$pagePosition){ pos in
            if !self.isReady  {return}
            
            if self.pageObservable.status == .initate{
                self.offsetX = pos.x
                self.offsetY = pos.y
            }else{
                if self.pageObject?.isAnimation == true {
                    if self.offsetX > pos.x || self.offsetY > pos.y {
                        withAnimation(.easeOut(duration: Self.pageMoveDuration)){
                            self.offsetX = pos.x
                            self.offsetY = pos.y
                        }
                    } else {
                        withAnimation(.easeIn(duration: Self.pageMoveDuration)){
                            self.offsetX = pos.x
                            self.offsetY = pos.y
                        }
                    }
                    
                }else{
                    self.offsetX = pos.x
                    self.offsetY = pos.y
                }
            }
        }
        .onReceive(self.pageObservable.$pageOpacity){ opacity in
            if !self.isReady {return}
            withAnimation{
                self.opacity = opacity
            }
        }
        .onReceive(self.pageObservable.$isInit){ isInit in
            if !isInit || self.isReady {return}
            self.initAnimation()
        }
        .onAppear{
            PageLog.log("onAppear",tag:self.pageID)
            self.offsetX = self.pageObservable.pagePosition.x
            self.offsetY = self.pageObservable.pagePosition.y
            if self.pageObject?.animationType == .opacity { self.opacity = 0 }
            if self.pageObject?.isAutoInit == true {
                self.initAnimation()
            }
        }
        .onDisappear{
            self.childView?.disAppear()
            self.pageObservable.status = .disAppear
            PageLog.log("onDisappear",tag:self.pageID)
            self.sceneObserver.event = .changed
        }
    }
    
    private func initAnimation(){
        self.isReady = true
        self.pageObservable.status = .appear
        self.pageObservable.pagePosition.x = 0
        self.pageObservable.pagePosition.y = 0
        self.pageObservable.pageOpacity = 1.0
        self.childView?.appear()
        self.sceneObserver.event = .changed
    }
    
    private func bellowAnimation(isBelow:Bool){
        self.isTop = false
        self.isBelow = isBelow
        self.dragOpacity = 1
        if !self.useBelowPageMove {return}
        switch self.topPageType {
        case .horizontal :
            self.pageOffsetX = Self.pageMoveAmount
            self.pageOffsetY = 0
        
        case .vertical :
            self.pageOffsetY = -Self.pageMoveAmount
            self.pageOffsetX = 0
        
        default : break
        }
    }
}

struct PageContent: PageView  {
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @EnvironmentObject var pageChanger:PagePresenter
    @State var bodyColor:Color = Color.red
    static internal var index = 0
    
    var body: some View {
        ZStack(){
            Rectangle().fill(bodyColor)
            VStack{
                Button<Text>(action: {
                    //self.pageChanger.changePage("Next" + PageContent.index.description)
                    PageContent.index += 1
                }) {
                    Text(pageObservable.isAnimationComplete ? pageID : "Loading")
                }
                Button<Text>(action: {
                    self.pageChanger.openPopup("Popup" + PageContent.index.description)
                    PageContent.index += 1
                }) {
                    Text("openPopup")
                }
                
                Button<Text>(action: {
                    self.pageChanger.closePopup(self.id)
                }) {
                    Text("closePopup")
                }
                
                Button<Text>(action: {
                    self.pageChanger.closeAllPopup()
                }) {
                    Text("closeAllPopup")
                }
                
                Button<Text>(action: {
                    self.pageChanger.goBack()
                }) {
                    Text("back")
                }
                if pageObservable.status == .becomeActive {
                    Text("BecomeActive")
                }
            }
            
        }
    }
}

#if DEBUG
struct PageContentBody_Previews: PreviewProvider {
    static var previews: some View {
        PageBackgroundBody()
    }
}
#endif
