//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
enum SceneSelect:Equatable {
    case select((String,[String]),Int, ((Int) -> Void)? = nil),
         selectBtn((String,[SelectBtnData]),Int, ((Int) -> Void)? = nil),
         picker((String,[String]),Int, pick:((Int) -> Void)? = nil),
         imgPicker(String, cameraDevice:UIImagePickerController.CameraDevice = .front, pick:((UIImage?) -> Void)? = nil)
    
    func check(key:String)-> Bool{
        switch (self) {
        case let .selectBtn(v, _, _): return v.0 == key
        case let .select(v, _, _): return v.0 == key
        case let .picker(v, _, _): return v.0 == key
        case let .imgPicker(v, _, _): return v.hasPrefix(key)
        }
    }
    
    static func ==(lhs: SceneSelect, rhs: SceneSelect) -> Bool {
        switch (lhs, rhs) {
        case (let .selectBtn(lh,_, _), let .selectBtn(rh,_, _)): return lh.0 == rh.0
        case (let .select(lh,_, _), let .select(rh,_, _)): return lh.0 == rh.0
        case (let .picker(lh,_, _), let .picker(rh,_, _)): return lh.0 == rh.0
        case (let .imgPicker(lv,_, _), let .imgPicker(rv,_, _)): return lv == rv
        default : return false
        }
    }
}
enum SceneSelectResult {
    case complete(SceneSelect,Int)
}

struct SceneSelectController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:AppSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @State var isShow = false
    @State var selected:Int = 0
    @State var buttons:[SelectBtnData] = []
    @State var currentSelect:SceneSelect? = nil
        
    var body: some View {
        Form{
            Spacer()
        }
        .select(
            isShowing: self.$isShow,
            index: self.$selected,
            buttons: self.buttons,
            cancel: {
                withAnimation{
                    self.isShow = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.reset()
                }
            }
        ){ idx in
            switch self.currentSelect {
            case .select(_ , _, let handler) , .selectBtn(_ , _, let handler) :
                if let handler = handler {
                    self.selectedSelect(idx ,data:self.currentSelect!, completionHandler: handler)
                } else {
                    self.selectedSelect(idx ,data:self.currentSelect!)
                }
                
            case .imgPicker(_, let cameraDevice , let handler):
                if let handler = handler {
                    switch idx {
                    case 0 :
                        self.appSceneObserver.event = .openImagePicker(self.tag, type: .photoLibrary, cameraDevice: cameraDevice, pick:handler)
                    case 1 :
                        self.appSceneObserver.event = .openImagePicker(self.tag, type: .camera, cameraDevice: cameraDevice, pick:handler)
                    default: handler(nil)
                    }
                } else {
                    self.selectedSelect(idx ,data:self.currentSelect!)
                }
            default: return
            }
            withAnimation{
                self.isShow = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reset()
            }
        }
        
        .onReceive(self.sceneObserver.$select){ select in
            self.currentSelect = select
            switch select{
                case .select(let data, let idx, _): self.setupSelect(data:data, idx: idx)
                case .selectBtn(let data, let idx, _): self.setupSelect(data:data, idx: idx)
                case .imgPicker(let key,_ ,_): self.setupImagePicker(key: key)
                default: return
            }
            withAnimation{
                self.isShow = true
            }
        }
        
    }//body
    
    func reset(){
        self.buttons = []
        self.currentSelect = nil
    }
    func setupImagePicker(key:String){
        self.selected = 2
        self.buttons = [
            .init(title: String.button.selectAlbum, index: 0, icon: Asset.icon.album),
            .init(title: String.button.takeCamera, index: 1, icon: Asset.icon.add_photo),
            .init(title: String.app.cancel, index: 2)
        ]
    }

    func setupSelect(data:(String,[String]), idx:Int) {
        self.selected = idx
        let range = 0 ..< data.1.count
        self.buttons = zip(range, data.1).map {index, text in
            SelectBtnData(title: text, index: index)
        }
    }
    func setupSelect(data:(String,[SelectBtnData]), idx:Int) {
        self.selected = idx
        self.buttons = data.1
    }
    
    func selectedSelect(_ idx:Int, data:SceneSelect, completionHandler: @escaping (Int) -> Void) {
        completionHandler(idx)
    }
    func selectedSelect(_ idx:Int, data:SceneSelect) {
        
        self.sceneObserver.selectResult = .complete(data, idx)
        self.sceneObserver.selectResult = nil
    }
    
   
}


