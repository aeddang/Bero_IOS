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
                    self.viewModel.playEvent = .resetMap
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
                                text: String.button.finishTheWalk,
                                size: Dimen.button.regular,
                                color: Color.app.black,
                                isActive: true
                            ){_ in
                                self.finishWalk()
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
        .onReceive(self.walkManager.$isSimpleView){ isSimple in
            withAnimation{
                self.isExpand = !isSimple
            }
        }
        .onAppear(){
            self.updatedPets()
        }
    }
    
    @State var walkTime:Double = 0
    @State var walkDistence:Double = 0
    @State var playExp:Int = 0
    @State var playPoint:Int = 0
    @State var pets:[PetProfile] = []
    
    private func finishWalk(){
        self.appSceneObserver.sheet = .select(
            String.pageText.walkFinishConfirm,
            nil,
            [String.app.cancel,String.button.finish]){ idx in
                if idx == 1 {
                    self.walkManager.endMission()
                    self.walkManager.completeWalk()
                }
            }
    }
    
    private func updatedPets(){
        self.pets = self.dataProvider.user.pets
    }
}


