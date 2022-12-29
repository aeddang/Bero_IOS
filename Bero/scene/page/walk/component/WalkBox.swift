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

struct WalkBox: PageComponent{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
    
    @Binding var isFollowMe:Bool
    @State var isExpand:Bool = true
    var body: some View {
        ZStack(alignment: .topTrailing){
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
                .opacity(self.isExpand ? 1 : 0)
                Spacer().modifier(MatchHorizontal(height: 0))
                CircleButton(
                    type: .icon(Asset.icon.my_location),
                    isSelected: false,
                    strokeWidth: Dimen.stroke.regular,
                    defaultColor: self.isFollowMe ? Color.app.blue : Color.app.grey500)
                { _ in
                    self.isFollowMe.toggle()
                    self.viewModel.playUiEvent = .resetMap
                }
            }
            if self.isExpand {
                ZStack(alignment: .top){
                    HStack(spacing:0){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        HStack(spacing:Dimen.margin.micro){
                            ForEach(self.pets) { profile in
                                WithPetItem(profile: profile)
                            }
                        }
                        .fixedSize()
                    }
                    VStack(alignment: .leading, spacing:Dimen.margin.thin){
                        Text(WalkManager.viewDistance(self.walkDistence))
                            .modifier(SemiBoldTextStyle(
                                size: Font.size.medium,
                                color: Color.app.grey500
                            ))
                            
                        LocationInfo(
                            time: WalkManager.viewDuration(self.walkTime)
                        )
                        HStack(spacing:Dimen.margin.micro){
                            RewardInfo(
                                type: .exp,
                                value: self.playExp
                            )
                            RewardInfo(
                                type: .point,
                                value: self.playPoint
                            )
                            FillButton(
                                type: .fill,
                                text: String.button.finish,
                                size: Dimen.button.regularExtra,
                                color: Color.app.black,
                                isActive: true
                            ){_ in
                                self.finishWalk()
                            }
                            if let mission = self.mission {
                                RectButton(
                                    sizeType: .tiny,
                                    icon: Asset.icon.goal,
                                    text: WalkManager.viewDistance(self.distenceFromMission),
                                    isSelected: true,
                                    color: Color.brand.primary
                                    ){_ in
                                    
                                        self.pagePresenter.closePopup(pageId: .popupWalkPlace)
                                        self.pagePresenter.closePopup(pageId: .popupWalkUser)
                                        
                                        if self.pagePresenter.hasPopup(find: .popupWalkMission) {
                                            self.pagePresenter.onPageEvent(
                                                self.pageObject,
                                                event: .init(id: PageID.popupWalkMission ,type: .pageChange, data: mission)
                                            )
                                            return
                                        }
                                        self.isFollowMe = false
                                        self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkMission).addParam(key: .data, value: mission))
                                }
                                .frame(width: RectButton.SizeType.tiny.bgSize)
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
                .padding(.top, Dimen.icon.mediumUltra + Dimen.margin.thin)
            }
        }
        .opacity(self.isShow ? 1 : 0)
        .onReceive(self.dataProvider.user.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .addedDog, .deletedDog, .updatedDogs : self.updatedPets()
            case .updatedPlayData :
                break
            default: break
            }
        }
        .onReceive(self.walkManager.$playExp){ exp in
            self.playExp = exp.toInt()
        }
        .onReceive(self.walkManager.$playPoint){ point in
            self.playPoint = point
        }
        .onReceive(self.walkManager.$walkTime){ time in
            self.walkTime = time
        }
        .onReceive(self.walkManager.$walkDistence){ distence in
            self.walkDistence = distence
        }
        .onReceive(self.walkManager.$currentMission){ mission in
            self.mission = mission
        }
        .onReceive(self.walkManager.$currentDistenceFromMission){ distence in
            self.distenceFromMission = distence ?? 0
        }
        .onReceive(self.walkManager.$isSimpleView){ isSimple in
            withAnimation{
                self.isExpand = !isSimple
            }
        }
        .onReceive(self.viewModel.$componentHidden){ isHidden in
            withAnimation{ self.isShow = !isHidden }
        }
        .onAppear(){
            self.updatedPets()
        }
    }
    @State var isShow:Bool = true
    @State var walkTime:Double = 0
    @State var walkDistence:Double = 0
    @State var playExp:Int = 0
    @State var playPoint:Int = 0
    @State var pets:[PetProfile] = []
    @State var mission:Mission? = nil
    @State var distenceFromMission:Double = 0
    private func finishWalk(){
        
        self.appSceneObserver.sheet = .select(
            String.pageText.walkFinishConfirm,
            String.alert.completedNeedPicture,
            [String.app.cancel,String.button.finish]){ idx in
                if idx == 1 {
                    self.walkManager.endMission()
                    self.walkManager.completeWalk()
                } else {
                    self.cancelWalk()
                }
            }
    }
    
    private func cancelWalk(){
        
        self.appSceneObserver.alert  = .confirm(nil, String.alert.completedExitConfirm){ isOk in
            
            self.walkManager.endMission()
            if isOk {
                self.walkManager.endWalk()
            } 
        }
    }
    
    private func updatedPets(){
        self.pets = self.dataProvider.user.pets
    }
}


