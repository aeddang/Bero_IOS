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
    case initate, toast(String), check(String, (() -> Void)? = nil), update(SceneUpdateType),
         debug(String), openImagePicker(String, type:UIImagePickerController.SourceType = .photoLibrary, pick:((UIImage?) -> Void)? = nil),
         sendChat(userId:String)
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
    @Published var sheet:SceneSheet? = nil
    @Published var sheetResult:SceneSheetResult? = nil {didSet{ if sheetResult != nil { sheetResult = nil} }}
    @Published var radio:SceneRadio? = nil
    @Published var radioResult:SceneRadioResult? = nil {didSet{ if radioResult != nil { radioResult = nil} }}
    @Published var select:SceneSelect? = nil
    @Published var selectResult:SceneSelectResult? = nil {didSet{ if selectResult != nil { selectResult = nil} }}
    @Published var event:SceneEvent? = nil {didSet{ if event != nil { event = nil} }}
    
    @Published var pickImage:PickImage? = nil {didSet{ if pickImage != nil { pickImage = nil} }}
    func cancelAll(){

    }
}



