//
//  SceneObserver.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

enum SceneUpdateType {
    case purchase(String, String?, String?)
}

enum SceneEvent {
    case initate, toast(String), update(SceneUpdateType),
         debug(String), openCamera(String)
}

enum SceneRequest:String {
    case imagePicker
}

struct PickImage {
    let id:String?
    let image:UIImage?
}

class AppSceneObserver:ObservableObject{
  
    @Published var useBottom = false
    @Published var useBottomImmediately = false
    @Published var isApiLoading = false
    @Published var safeHeaderHeight:CGFloat = 0
    @Published var headerHeight:CGFloat = 0
    
    @Published var safeBottomHeight:CGFloat = 0
    
    @Published var loadingInfo:[String]? = nil
    @Published var alert:SceneAlert? = nil
    @Published var alertResult:SceneAlertResult? = nil {didSet{ if alertResult != nil { alertResult = nil} }}
    @Published var radio:SceneRadio? = nil
    @Published var radioResult:SceneRadioResult? = nil {didSet{ if radioResult != nil { radioResult = nil} }}
    @Published var select:SceneSelect? = nil
    @Published var selectResult:SceneSelectResult? = nil {didSet{ if selectResult != nil { selectResult = nil} }}
    @Published var event:SceneEvent? = nil {didSet{ if event != nil { event = nil} }}
    
    @Published var pickImage:PickImage? = nil {didSet{ if pickImage != nil { pickImage = nil} }}
    func cancelAll(){

    }
}

enum SceneSelect:Equatable {
    case select((String,[String]),Int, ((Int) -> Void)? = nil),
         selectBtn((String,[SelectBtnData]),Int, ((Int) -> Void)? = nil),
         picker((String,[String]),Int), imgPicker(String)
    
    func check(key:String)-> Bool{
        switch (self) {
        case let .selectBtn(v, _, _): return v.0 == key
        case let .select(v, _, _): return v.0 == key
        case let .picker(v, _): return v.0 == key
        case let .imgPicker(v): return v.hasPrefix(key)
        }
    }
    
    static func ==(lhs: SceneSelect, rhs: SceneSelect) -> Bool {
        switch (lhs, rhs) {
        case (let .selectBtn(lh,_, _), let .selectBtn(rh,_, _)): return lh.0 == rh.0
        case (let .select(lh,_, _), let .select(rh,_, _)): return lh.0 == rh.0
        case (let .picker(lh,_), let .picker(rh,_)): return lh.0 == rh.0
        case (let .imgPicker(lv), let .imgPicker(rv)): return lv == rv
        default : return false
        }
    }
}
enum SceneSelectResult {
    case complete(SceneSelect,Int)
}

