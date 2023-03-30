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

struct PlayBox: PageComponent{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
    
    @Binding var isFollowMe:Bool
    var isInitable:Bool = false
    var body: some View {
        VStack(){
            HStack(spacing:0){
                CircleButton(
                    type: .icon(self.isExpand ? Asset.icon.minimize : Asset.icon.maximize),
                    isSelected: false,
                    strokeWidth: Dimen.stroke.regular,
                    defaultColor: self.isExpand ? Color.app.grey500 : Color.brand.primary)
                { _ in
                    withAnimation{
                        self.isExpand.toggle()
                    }
                    self.walkManager.updateSimpleView(!self.isExpand)
                }
                .opacity(self.isExpand && self.isWalk ? 1 : 0)
                
                Spacer().modifier(MatchHorizontal(height: 0))
                SortButton(
                    type: .stroke,
                    sizeType: .small,
                    icon: Asset.icon.refresh,
                    text: String.button.searchArea,
                    color: Color.brand.primary,
                    isSort: false,
                    isSelected: false
                )
                {
                    guard let loc = self.viewModel.position else {return}
                    let viewLoc = CLLocation(latitude: loc.target.latitude, longitude: loc.target.longitude)
                    self.walkManager.replaceMapStatus(viewLoc)
                    self.walkManager.uiEvent = .moveMap(viewLoc, zoom:PlayMap.zoomDefault)
                }
                .fixedSize()
                
                Spacer().modifier(MatchHorizontal(height: 0))
                CircleButton(
                    type: .icon(Asset.icon.my_location),
                    isSelected: false,
                    strokeWidth: Dimen.stroke.regular,
                    defaultColor: self.isFollowMe ? Color.brand.primary : Color.app.grey500)
                { _ in
                    self.isFollowMe.toggle()
                    self.viewModel.playUiEvent = .resetMap
                }
            }
            HStack(spacing:Dimen.margin.thin){
                if self.isWalk {
                    CircleButton(
                        type: .icon(Asset.icon.camera, size: Dimen.icon.heavyExtra),
                        isSelected: true,
                        defaultColor:Color.app.white,
                        activeColor: Color.app.black
                    ){_ in
                        self.openPicker()
                    }
                }
                
                FillButton(
                    type: .fill,
                    text: self.isWalk ? String.button.finishTheWalk : String.button.startWalking,
                    size: Dimen.button.regular,
                    color:  self.isWalk ? Color.app.black : Color.brand.primary,
                    isActive: true
                ){_ in
                    if self.isWalk {
                        self.finishWalk()
                    } else {
                        if self.isInitable {
                            self.startWalk()
                        } else {
                            self.needDog()
                        }
                    }
                }
            }
            .padding(.all, Dimen.margin.regularExtra)
            .background(Color.app.white )
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
            .overlay(
                RoundedRectangle(cornerRadius: Dimen.radius.light)
                    .strokeBorder(
                        Color.app.grey100,
                        lineWidth: Dimen.stroke.light
                    )
            )
            .modifier(ShadowLight( opacity: 0.05 ))
        }
        .opacity(self.isShow && self.isExpand ? 1 : 0)
        .onReceive(self.viewModel.$componentHidden){ isHidden in
            withAnimation{ self.isShow = !isHidden }
        }
        .onReceive(self.walkManager.$isSimpleView){ isSimple in
            withAnimation{
                self.isExpand = !isSimple
            }
        }
        .onReceive(self.walkManager.$status){ status in
            if !self.isInit {
                self.isInit = true
                self.isWalk = status == .walking
            } else {
                withAnimation{
                    self.isWalk = status == .walking
                }
            }
            
        }
        .onAppear(){
            self.isExpand = !self.walkManager.isSimpleView
        }
    }
    @State var isExpand:Bool = false
    @State var isShow:Bool = true
    @State var isInit:Bool = false
    @State var isWalk:Bool = false
    private func openPicker(){
        if !self.walkManager.updateAbleCheck() {return}
        self.appSceneObserver.event = .openImagePicker(self.tag, type: .camera, cameraDevice: .rear){ img in
            guard let img = img else { return }
            self.pickImage(img)
        }
    }

    private func pickImage(_ img:UIImage) {
        self.pagePresenter.isLoading = true
        DispatchQueue.global(qos:.background).async {
            let size = CGSize(
                width: AlbumApi.originSize,
                height: AlbumApi.originSize)
            let image = img.normalized().crop(to: size).resize(to: size)
            
            let sizeList = CGSize(
                width: AlbumApi.thumbSize,
                height: AlbumApi.thumbSize)
            let thumbImage = img.normalized().crop(to: sizeList).resize(to: sizeList)
            DispatchQueue.main.async {
                self.pagePresenter.isLoading = false
                self.walkManager.updateStatus(img: image, thumbImage: thumbImage)
            }
        }
    }
    
    private func startWalk(){
        if  self.walkManager.currentLocation == nil {
            self.appSceneObserver.event = .toast(String.pageText.walkLocationNotFound)
            return
        }
        if self.dataProvider.user.pets.count >= 2 {
            self.pagePresenter.openPopup(PageProvider.getPageObject(.popupChooseDog))
            return
        }
        self.walkManager.requestWalk()
    }
    
    private func finishWalk(){
        self.appSceneObserver.sheet = .select(
            String.pageText.walkFinishConfirm,
            String.alert.completedNeedPicture,
            [String.app.cancel,String.button.finish]){ idx in
                if idx == 1 {
                    self.checkFinish()
                } else {
                    self.cancelWalk()
                }
            }
    }
    private func checkFinish(){
        if !SystemEnvironment.isTestMode && self.walkManager.walkDistance < WalkManager.minDistance {
            self.appSceneObserver.alert  = .alert(nil,String.pageText.walkFinishCheckDistance.replace(WalkManager.minDistance.description))
            return
        }
        self.walkManager.endMission()
        self.walkManager.completeWalk()
    }
    private func cancelWalk(){
        
        self.appSceneObserver.alert  = .confirm(nil, String.alert.completedExitConfirm){ isOk in
            
            self.walkManager.endMission()
            if isOk {
                self.walkManager.endWalk()
            }
        }
    }
    
    private func needDog(){
        if !self.dataProvider.user.pets.isEmpty { return }
        self.appSceneObserver.sheet = .select(
            String.alert.addDogTitle,
            String.alert.addDogText,
            image:Asset.image.addDog,
            [String.button.later,String.button.ok]){ idx in
                if idx == 1 {
                    self.pagePresenter.openPopup(PageProvider.getPageObject(.addDog))
                }
        }
    }
}


