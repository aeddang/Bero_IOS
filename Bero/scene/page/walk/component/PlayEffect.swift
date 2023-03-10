//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps
import GooglePlaces
import QuartzCore


enum PlayEffectType {
    case image, count, text, animation
}
class PlayEffectItem:Identifiable{
    let id:String = UUID().uuidString
    fileprivate var type:PlayEffectType = .image
    fileprivate var value:String = ""
    fileprivate var duration:Int = 3
    fileprivate var isFullScreen:Bool = false
    fileprivate var snd:String? = nil
    fileprivate var isFind:Bool? = nil
    fileprivate var font:TextModifier = .init(family: Font.family.bold, size: 48, color: Color.brand.primary)
    fileprivate var size:CGSize = .init(width: 100, height: 100)
    fileprivate var position:CGPoint = .init(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/3)
    fileprivate var bgColor:Color? = nil
}

struct PlayEffect: PageView {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
    @Binding var isFollowMe:Bool
    @State var effects:[PlayEffectItem] = []
    @State var isFindEffect:Bool = false
    @State var isWalking:Bool = false
    @State var followMeColor:Color = Color.app.blue
    @State var backGroundColor:Color? = nil
    var body: some View {
        ZStack(alignment: .center){
            if let color = self.backGroundColor {
                Spacer().modifier(MatchParent())
                    .background(color)
            }
            ForEach(self.effects) { effect in
                switch effect.type {
                case .animation :
                    PlayEffectAnimation(data: effect){
                        if effect.duration > 0 {
                            self.remove(id: effect.id)
                        }
                    }
                    .position(effect.position)
                    .onTapGesture{
                        self.remove(id: effect.id)
                    }
                case .count :
                    PlayEffectCount(data:effect){
                        self.remove(id: effect.id)
                    }
                    .position(effect.position)
                    Spacer().modifier(MatchParent()).background(Color.transparent.clearUi)
                case .image :
                    PlayEffectImage(data:effect){
                        self.remove(id: effect.id)
                    }
                    .position(effect.position)
                    .onAppear{
                        if let find = effect.isFind {
                            if find {
                                self.findShow()
                            } else {
                                self.findShowCancel()
                            }
                        }
                    }
                case .text :
                    PlayEffectText(data:effect){
                        self.remove(id: effect.id)
                    }
                    .onAppear{
                        if let find = effect.isFind {
                            if find {
                                self.findShow()
                            } else {
                                self.findShowCancel()
                            }
                        }
                    }
                    .position(effect.position)
                }
            }
            
            if self.isFindEffect {
                CircleWave()
                    .position(.init(
                        x: UIScreen.main.bounds.width/2,
                        y: UIScreen.main.bounds.height/2 - 40
                    ))
            } else if self.isFollowMe && self.isWalking {
                CircleWave(color: self.followMeColor)
            }
        }
        
        .onReceive(self.viewModel.$playEffectEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .missionPlayStart :
                let eff = PlayEffectItem()
                eff.type = .animation
                eff.value = "bero_mission_start"
                eff.snd = Asset.sound.mission
                eff.size = .init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.add(effect: eff)
            case .viewRoute(let duration) :
                let eff = PlayEffectItem()
                eff.type = .count
                eff.duration = duration.toInt()
                eff.value = "1"
                eff.position = .init(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 60 )
                self.add(effect: eff)
            }
        }
        .onReceive(self.walkManager.$status){ status in
            switch status {
            case .ready :
                self.followMeColor = Color.app.blue
                self.isWalking = false
            case .walking :
                self.followMeColor = Color.brand.primary
                self.isWalking = true
            }
        }
        .onReceive(self.walkManager.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
          
            case .viewTutorial(let resource) :
                let eff = PlayEffectItem()
                eff.type = .animation
                eff.value = resource
                eff.duration = -1
                eff.isFullScreen = true
                eff.size = .init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                eff.position = .init(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
                eff.bgColor = Color.transparent.black70
                self.add(effect: eff)
            
                break
            case .startMission:
                let eff = PlayEffectItem()
                eff.type = .text
                eff.duration = 3
                eff.value = "Ready"
                eff.snd = Asset.sound.ready
                self.add(effect: eff)
    
            case .completedMission:
                let eff = PlayEffectItem()
                eff.type = .text
                eff.duration = 3
                eff.value = "Mission\nComplete!"
                eff.snd = Asset.sound.end

                self.add(effect: eff)
                
            case .findPlace :
                let eff = PlayEffectItem()
                eff.type = .text
                eff.duration = 3
                eff.value = "Find place!"
                eff.snd = Asset.sound.find
                eff.isFind = true
                self.add(effect: eff)
            default: break
            }
        }
        
    }//body
    private func add(effect:PlayEffectItem){
        if effect.isFullScreen {
            self.appSceneObserver.useBottom = false
        }
        self.effects.append(effect)
        if let color = effect.bgColor {
            withAnimation{
                self.backGroundColor = color
            }
        }
        ComponentLog.d("self.effects " + self.effects.count.description, tag: self.tag)
    }
    private func remove(id:String){
        if let find = self.effects.firstIndex(where: {$0.id == id}){
            self.effects.remove(at: find)
            self.appSceneObserver.useBottom = true
        }
        ComponentLog.d("self.effects " + self.effects.count.description, tag: self.tag)
        if self.effects.isEmpty {
            withAnimation{
                self.backGroundColor = nil
            }
        }
        if let bg = self.effects.first(where: {$0.bgColor != nil}){
            withAnimation{
                self.backGroundColor = bg.bgColor
            }
        } else {
            withAnimation{
                self.backGroundColor = nil
            }
        }
    }
    
    @State var findShowSubscription:AnyCancellable?
    func findShow() {
        withAnimation{
            self.isFindEffect = true
        }
        self.findShowSubscription?.cancel()
        self.findShowSubscription = Timer.publish(
            every: 4, on: .main, in: .common)
            .autoconnect()
            .sink() {_ in
                self.findShowCancel()
        }
    }
    
    func findShowCancel() {
        self.findShowSubscription?.cancel()
        self.findShowSubscription = nil
        withAnimation{
            self.isFindEffect = false
        }
    }
}

struct PlayEffectImage: PageView {
    let data:PlayEffectItem
    let complete: (() -> Void)
    var body: some View {
        Image(self.data.value)
        .renderingMode(.original)
        .resizable()
        .scaledToFit()
        .frame(width: self.data.size.width, height: self.data.size.height)
        .opacity(self.isShow ? 1 : 0)
        .offset(y: self.isShow ? 0 : -50)
        .onAppear(){
            self.progress()
        }
        .onDisappear{
            self.progressSubscription?.cancel()
            self.progressSubscription = nil
        }
    }//body
    @State var isShow:Bool = false
    @State var progressSubscription:AnyCancellable?
    func progress() {
        if let snd = self.data.snd {
            SoundToolBox().play(snd:snd)
        }
        
        self.progressSubscription?.cancel()
        let end = self.data.duration
        var count = 0
        withAnimation{
            self.isShow = true
        }
        
        self.progressSubscription = Timer.publish(
            every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink() {_ in
                if count == end-1 {
                    withAnimation{
                        self.isShow = false
                    }
                }
                if count == end {
                    self.progressSubscription?.cancel()
                    self.complete()
                }
                count += 1
        }
    }
    
}

struct PlayEffectText: PageView {
    let data:PlayEffectItem
    let complete: (() -> Void)
    var body: some View {
        ZStack{
            Spacer().modifier(MatchHorizontal(height: 0))
            Text(self.data.value)
                .modifier(CustomTextStyle(textModifier: self.data.font))
                .padding(.all,Dimen.margin.regular)
        }
        .background(Color.app.orange.opacity(0.2))
        /*
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius:Dimen.radius.medium)
                .strokeBorder(
                    Color.app.white,
                    lineWidth: Dimen.stroke.medium
                )
        )
        .modifier(Shadow())
        */
        .opacity(self.isShow ? 1 : 0)
        .offset(x: self.isShow ? 0 : self.isStart ? -200 : 200)
        .onAppear(){
            self.progress()
        }
        .onDisappear{
            self.progressSubscription?.cancel()
            self.progressSubscription = nil
        }
    }//body
    @State var isStart:Bool = true
    @State var isShow:Bool = false
    @State var progressSubscription:AnyCancellable?
    func progress() {
        if let snd = self.data.snd {
            SoundToolBox().play(snd:snd)
        }
        
        self.progressSubscription?.cancel()
        let end = self.data.duration
        var count = 0
        withAnimation{
            self.isShow = true
        }
        self.progressSubscription = Timer.publish(
            every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink() {_ in
                if count == end-1 {
                    self.isStart = false
                    withAnimation{
                        self.isShow = false
                    }
                }
                if count == end {
                    self.progressSubscription?.cancel()
                    self.complete()
                }
                count += 1
        }
    }
}

struct PlayEffectCount: PageView {
    let data:PlayEffectItem
    let complete: (() -> Void)
    var body: some View {
        Text(self.viewText)
            .modifier(CustomTextStyle(textModifier: self.data.font))
            .padding(.horizontal,Dimen.margin.regular)
            .background(Color.app.orange.opacity(0.2))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(
                        Color.app.white,
                        lineWidth: Dimen.stroke.medium
                    )
            )
            .opacity(self.isShow ? 1 : 0)
            .offset(y: self.isShow ? 0 : -50)
        
            .onAppear(){
                self.progress()
                
            }
            .onDisappear{
                self.progressSubscription?.cancel()
                self.progressSubscription = nil
            }
    }//body
    @State var viewText:String = ""
    @State var isShow:Bool = false
    @State var progressSubscription:AnyCancellable?
    func progress() {
        if let snd = self.data.snd {
            SoundToolBox().play(snd:snd)
        }
        self.progressSubscription?.cancel()
        let end = self.data.duration
        var count = 0
        withAnimation{
            self.isShow = true
        }
        self.progressSubscription = Timer.publish(
            every: 1, on: .main, in: .common)
            .autoconnect()
            .sink() {_ in
               
                if count == end {
                    self.progressSubscription?.cancel()
                    self.complete()
                } else {
                    SoundToolBox().play(snd:Asset.sound.tick)
                }
                count += 1
                if count == end {
                    withAnimation{
                        self.isShow = false
                    }
                    self.viewText = self.data.value.isEmpty ? (end-count).description : self.data.value
                } else {
                    self.viewText = (end-count).description
                }
               
        }
    }
}

struct PlayEffectAnimation: PageView {
    
    let data:PlayEffectItem
    let complete: (() -> Void)
    var body: some View {
        LottieView(lottieFile: self.data.value){
            complete()
        }
        .frame(width: self.data.size.width, height: self.data.size.height)
        .onAppear(){
            
            if let snd = self.data.snd {
                SoundToolBox().play(snd:snd, ext:"wav")
            }
        }
        .onDisappear{
            
        }
    }//body
}
