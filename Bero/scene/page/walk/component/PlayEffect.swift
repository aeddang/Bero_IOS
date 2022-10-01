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
    case image, count, text
}
class PlayEffectItem:Identifiable{
    let id:String = UUID().uuidString
    fileprivate var type:PlayEffectType = .image
    fileprivate var value:String = ""
    fileprivate var duration:Int = 3
    fileprivate var snd:String? = nil
    fileprivate var font:TextModifier = .init(family: Font.family.bold, size: 60, color: Color.brand.primary)
    fileprivate var size:CGSize = .init(width: 100, height: 100)
    fileprivate var position:CGPoint = .init(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
}

struct PlayEffect: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
    @State var effects:[PlayEffectItem] = []
    var body: some View {
        ZStack(alignment: .center){
            ForEach(self.effects) { effect in
                switch effect.type {
                case .count :
                    PlayEffectCount(data:effect){
                        self.remove(id: effect.id)
                    }
                    .position(effect.position)
                case .image :
                    PlayEffectImage(data:effect){
                        self.remove(id: effect.id)
                    }
                    .position(effect.position)
                case .text :
                    PlayEffectText(data:effect){
                        self.remove(id: effect.id)
                    }
                    .position(effect.position)
                }
            }
        }
        .onReceive(self.viewModel.$playEffectEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .missionPlayStart :
                let eff = PlayEffectItem()
                eff.type = .text
                eff.duration = 3
                eff.value = "STaRT!!"
                eff.snd = Asset.sound.start
                self.add(effect: eff)
            }
        }
        .onReceive(self.walkManager.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .start :
                let eff = PlayEffectItem()
                eff.type = .count
                eff.duration = 4
                eff.value = "WaLk StART"
                eff.snd = Asset.sound.start
                self.add(effect: eff)
                
            case .getRoute :
                let eff = PlayEffectItem()
                eff.type = .count
                eff.duration = 3
                eff.position = .init(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 60 )
                self.add(effect: eff)
     
            case .startMission:
                let eff = PlayEffectItem()
                eff.type = .text
                eff.duration = 3
                eff.value = "ReAdy~"
                eff.snd = Asset.sound.ready
                self.add(effect: eff)
    
            case .completedMission:
                let eff = PlayEffectItem()
                eff.type = .text
                eff.duration = 3
                eff.value = "CoMPlET!!"
                eff.snd = Asset.sound.end
                self.add(effect: eff)
                
            case .findPlace :
                let eff = PlayEffectItem()
                eff.type = .text
                eff.duration = 3
                eff.value = "FiND pLACE!!"
                eff.snd = Asset.sound.success
                self.add(effect: eff)
            default: break
            }
        }
        
    }//body
    private func add(effect:PlayEffectItem){
        self.effects.append(effect)
        ComponentLog.d("self.effects " + self.effects.count.description, tag: self.tag)
    }
    private func remove(id:String){
        if let find = self.effects.firstIndex(where: {$0.id == id}){
            self.effects.remove(at: find)
        }
        ComponentLog.d("self.effects " + self.effects.count.description, tag: self.tag)
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
        Text(self.data.value)
            .modifier(CustomTextStyle(textModifier: self.data.font))
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

struct PlayEffectCount: PageView {
    let data:PlayEffectItem
    let complete: (() -> Void)
    var body: some View {
        Text(self.viewText)
            .modifier(CustomTextStyle(textModifier: self.data.font))
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
                SoundToolBox().play(snd:"sample") //Asset.sound.ready)
                if count == end {
                    self.progressSubscription?.cancel()
                    self.complete()
                }
                count += 1
                if count == end {
                    withAnimation{
                        self.isShow = false
                    }
                    self.viewText = self.data.value.isEmpty ? count.description : self.data.value
                } else {
                    self.viewText = count.description
                }
               
        }
    }
}

