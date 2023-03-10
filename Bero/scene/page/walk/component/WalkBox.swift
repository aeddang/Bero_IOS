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
    
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            HStack(alignment: .top, spacing:0) {
                VStack(alignment: .leading, spacing:0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    Text(self.title)
                        .modifier(SemiBoldTextStyle(
                            size: Font.size.regular,
                            color: self.isWalk ? Color.brand.primary : Color.app.grey500
                        ))
                        .multilineTextAlignment(.leading)
                        .opacity(self.isExpand ? 1 : 0)
                }
                ImageButton(
                    isSelected: false,
                    defaultImage:Asset.icon.search_user,
                    type: .original,
                    size: .init(width: Dimen.icon.heavyExtra, height: Dimen.icon.heavyExtra)
                ){_ in
                    self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkUsers))
                }
                .frame( alignment: .center)
            }
            
            if self.isWalk {
                HStack(spacing:Dimen.margin.tiny){
                    PropertyInfo(
                        type: .impect,
                        value: self.walkTime,
                        unit:String.app.time
                    )
                    PropertyInfo(
                        type: .impect,
                        value: self.walkDistance,
                        unit:String.app.km
                    )
                }
                .padding(.top, Dimen.margin.thin)
                .opacity(self.isExpand ? 1 : 0)
            } else {
                LocationInfo()
                    .padding(.top, Dimen.margin.medium)
                    .opacity(self.isExpand ? 1 : 0)
            }
        }
        .padding(.all, self.isExpand ? Dimen.margin.regularExtra : 0)
        .background( self.isExpand ? Color.app.white : Color.transparent.clear)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
        .overlay(
            RoundedRectangle(cornerRadius: Dimen.radius.light)
                .strokeBorder(
                    Color.app.grey100,
                    lineWidth:  self.isExpand ? Dimen.stroke.light : 0
                )
        )
        .modifier(ShadowLight( opacity: self.isExpand ? 0.05 : 0 ))
        .opacity(self.isShow ? 1 : 0)
        .onReceive(self.dataProvider.user.$representativePet){ _ in
            self.updateTitle()
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
            self.updateTitle()
        }
        .onReceive(self.walkManager.$walkTime){ time in
            self.walkTime = WalkManager.viewDuration(time)
        }
        .onReceive(self.walkManager.$walkDistance){ distance in
            self.walkDistance = WalkManager.viewDistance(distance)
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
            self.isExpand = !self.walkManager.isSimpleView
        }
        
    }
    @State var isInit:Bool = false
    @State var isShow:Bool = true
    @State var isExpand:Bool = true
    @State var isWalk:Bool = false
    @State var walkTime:String = "00:00"
    @State var walkDistance:String = "0"
    @State var title:String = ""
    
    private func updateTitle(){
        if self.isWalk {
            self.title = String.pageText.walkPlayText
        } else {
            let name = self.dataProvider.user.representativePet?.name ?? self.dataProvider.user.currentProfile.nickName ?? ""
            self.title = String.pageText.walkStartText.replace(name)
        }
        
    }
}


