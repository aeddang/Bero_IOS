//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Foundation
import SwiftUI
struct SceneTab: PageComponent{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var imagePickerModel = ImagePickerModel()
    @State var positionBottom:CGFloat = -Dimen.app.bottom
    @State var isDimed:Bool = false
    @State var isSimpleWalkView:Bool = false
    @State var isSimpleWalkPositionTop:Bool = false
    @State var safeAreaTop:CGFloat = 0
    @State var safeAreaBottom:CGFloat = 0
    @State var useBottom:Bool = false
    @State var isActiveChat:Bool = false
    @State var toastMsg:String = ""
    @State var isToastShowing:Bool = false
    
    @State var checkMsg:String = ""
    @State var isAutoCheck:Bool = false
    @State var isCheckShowing:Bool = false
    @State var checked: (() -> Void)? = nil
   
    @State var isShowCamera:Bool = false
    @State var cameraType:UIImagePickerController.SourceType = .camera
    @State var cameraDevice:UIImagePickerController.CameraDevice = .front
    @State var imagePick:((UIImage?)->Void)? = nil
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing:0){
                if self.isSimpleWalkPositionTop {
                    SimpleWalkBox()
                        .offset(x: self.isSimpleWalkView ? -SimpleWalkBox.offset : -200 )
                        .padding(.top, self.appSceneObserver.safeHeaderHeight)
                }
                Spacer()
                if !self.isSimpleWalkPositionTop {
                    SimpleWalkBox()
                        .offset(x: self.isSimpleWalkView ? -SimpleWalkBox.offset : -200 )
                        .padding(.bottom, Dimen.margin.thin
                                 + (self.isActiveChat ? (Dimen.app.chatBox + self.sceneObserver.safeAreaBottom) : 0))
                }
                BottomTab()
                    .padding(.bottom, self.positionBottom)
                    .opacity(self.useBottom ? 1 : 0)
            }
            if self.isDimed {
                Button(action: {
                    self.appSceneObserver.cancelAll()
                }) {
                    Spacer().modifier(MatchParent())
                        .background(Color.transparent.black45)
                }
            }
            if self.isShowCamera {
                CustomImagePicker(
                    viewModel:self.imagePickerModel,
                    sourceType: self.cameraType,
                    cameraDevice: self.cameraDevice
                )
                .edgesIgnoringSafeArea(.all)
                .onReceive(self.imagePickerModel.$event){ evt in
                    guard let evt = evt else { return }
                    switch evt {
                    case .cancel :
                        if let pick = self.imagePick {
                            pick(nil)
                            self.imagePick = nil
                        }
                        withAnimation{
                            self.isShowCamera = false
                        }
                    default : break
                    }
                }
                .onReceive(self.imagePickerModel.$pickImage){ img in
                    guard let img = img else { return }
                    DispatchQueue.main.async {
                        if let pick = self.imagePick {
                            pick(img)
                            self.imagePick = nil
                        }
                        self.appSceneObserver.pickImage = PickImage(id:self.imagePickerModel.pickId, image: img)
                    }
                    withAnimation{
                        self.isShowCamera = false
                    }
                }
            }
            ChatBox(isActive :self.$isActiveChat)
            Spacer().modifier(MatchParent())
                .check(isShowing: self.$isCheckShowing , text: self.checkMsg,
                       isAuto: self.isAutoCheck, action: self.checked)
            Spacer().modifier(MatchParent())
                .toast(isShowing: self.$isToastShowing , text: self.toastMsg)
        }
        .modifier(MatchParent())
        .onReceive(self.walkManager.$isSimpleView) { isSimple in
            withAnimation{
                self.isSimpleWalkView = isSimple
            }
        }
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            guard let pageId = page?.pageID else {return}
            if page?.isLayer == true {return}
            switch pageId {
            case .walk :
                if !self.isSimpleWalkPositionTop {
                    withAnimation{self.isSimpleWalkPositionTop = true}
                    self.walkManager.updateSimpleView(false)
                }
            case .walkCompleted, .missionCompleted : break
            default :
                if self.isSimpleWalkPositionTop {
                    withAnimation{self.isSimpleWalkPositionTop = false}
                    self.walkManager.updateSimpleView(true)
                }
            }
            
        }
        .onReceive (self.sceneObserver.$safeAreaTop){ pos in
            if self.safeAreaTop != pos {
                self.safeAreaTop = pos
            }
        }
        .onReceive (self.sceneObserver.$safeAreaBottom){ pos in
            if self.safeAreaBottom != pos {
                self.safeAreaBottom = pos
                self.updateBottomPos()
            }
        }
        .onReceive (self.appSceneObserver.$useBottom) { use in
            withAnimation{
                self.useBottom = use
            }
            self.updateBottomPos()
        }
       
        .onReceive (self.appSceneObserver.$useBottomImmediately) { use in
            self.useBottom = use
            self.updateBottomPos()
        }
        .onReceive(self.appSceneObserver.$selectResult){ result in
            guard let result = result else { return }
            switch result {
                case .complete(let type, let idx) : do {
                    switch type {
                    case .imgPicker(let id, let cameraDevice,  _):
                        if type.check(key: SceneRequest.imagePicker.rawValue) {
                            if idx != 2 {
                                self.imagePickerModel.pickId = id
                                self.cameraDevice = cameraDevice
                                self.cameraType = idx == 0 ? .savedPhotosAlbum : .camera
                                withAnimation{
                                    self.isShowCamera = true
                                }
                            } else {
                                self.appSceneObserver.pickImage = PickImage(id:id,image: nil)
                            }
                        }
                    default : break
                    }
                    
                }
            }
        }
        .onReceive(self.appSceneObserver.$event){ evt in
            guard let evt = evt else { return }
            switch evt  {
            case .check(let msg, let checked):
                self.checkMsg = msg
                self.checked = checked
                self.isAutoCheck = checked == nil
                withAnimation{
                    self.isCheckShowing = true
                }
            case .toast(let msg):
                self.toastMsg = msg
                withAnimation{
                    self.isToastShowing = true
                }
            case .debug(let msg):
                #if DEBUG
                    self.toastMsg = msg
                    withAnimation{
                        self.isToastShowing = true
                    }
                #endif
                break
            case .openImagePicker(let pickId, let type, let cameraDevice, let pick) :
                self.imagePickerModel.pickId = pickId
                self.cameraType = type
                self.cameraDevice = cameraDevice
                self.imagePick = pick
                withAnimation{
                    self.isShowCamera = true
                }
            default: break
            }
        }
        
    }
    
    func updateBottomPos(){
        withAnimation{
            self.positionBottom = self.appSceneObserver.useBottom
                ? 0
                : -(Dimen.app.bottom+self.safeAreaBottom)
        }
    }
    
    
    
}

#if DEBUG
struct SceneTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SceneTab()
            .environmentObject(AppObserver())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(PagePresenter())
                .frame(width:340,height:300)
        }
    }
}
#endif
