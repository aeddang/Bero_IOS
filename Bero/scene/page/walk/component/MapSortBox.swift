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

struct MapSortBox: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
   
    var body: some View {
        HStack(spacing:Dimen.margin.tinyExtra){
            if self.isShow {
                SortButton(
                    type: .stroke,
                    sizeType: .small,
                    icon: WalkManager.SortType.user.icon,
                    text: self.userFilter.getTitle(type: .user),
                    color: self.userFilter.isActive ? Color.brand.primary :  Color.app.grey300,
                    isSort: false
                )
                {
                    self.onSort(.user)
                }
                if self.showMissionFilter {
                    SortButton(
                        type: .stroke,
                        sizeType: .small,
                        icon: WalkManager.SortType.mission.icon,
                        text: self.missionFilter.getTitle(type: .mission),
                        color: self.missionFilter.isActive ? Color.brand.primary :  Color.app.grey300,
                        isSort: false
                    )
                    {
                        self.onSort(.mission)
                    }
                }
                
                SortButton(
                    type: .stroke,
                    sizeType: .small,
                    icon: WalkManager.SortType.place.icon,
                    text: self.placeFilter.getTitle(type: .place),
                    color: self.placeFilter.isActive ? Color.brand.primary :  Color.app.grey300,
                    isSort: false
                )
                {
                    self.onSort(.place)
                }
            }
            CircleButton(
                type: .icon(Asset.icon.filter_filled, size: Dimen.icon.medium),
                isSelected: self.isShow,
                strokeWidth: Dimen.stroke.regular
            )
            { _ in
                withAnimation{
                    self.isShow.toggle()
                }
            }
        }
        .onReceive(self.walkManager.$currentMission){ mission in
            withAnimation{
                self.showMissionFilter = mission == nil
            }
            
        }
        .onAppear{
            self.userFilter = self.walkManager.userFilter
            self.placeFilter = self.walkManager.placeFilter
            self.missionFilter = self.walkManager.missionFilter
        }
    }//body
    @State var isShow:Bool = true
    @State var userFilter:WalkManager.Filter = .all
    @State var placeFilter:WalkManager.Filter = .shop
    @State var missionFilter:WalkManager.Filter = .all
    @State var showMissionFilter:Bool = true
    private func onSort(_ type:WalkManager.SortType){
        self.pagePresenter.closePopup(pageId: .popupWalkPlace)
        self.pagePresenter.closePopup(pageId: .popupWalkMission)
        self.pagePresenter.closePopup(pageId: .popupWalkUser)
        
        let datas:[String] = type.filter.map{$0.getText(type: type)}
        var changeUserFilter:WalkManager.Filter? = nil
        var changePlaceFilter:WalkManager.Filter? = nil
        var changeMissionFilter:WalkManager.Filter? = nil
        self.appSceneObserver.radio = .sort((self.tag, datas), title: type.title + " " + String.app.filter.lowercased()){ idx in
            guard let idx = idx else {return}
            switch type {
            case .user :
                self.userFilter = type.filter[idx]
                changeUserFilter = self.userFilter
            case .mission :
                self.missionFilter = type.filter[idx]
                changeMissionFilter = self.missionFilter
            case .place :
                self.placeFilter = type.filter[idx]
                changePlaceFilter = self.placeFilter
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                guard let loc = self.walkManager.currentLocation else {return}
               
                self.walkManager.resetMapStatus(
                    loc,
                    userFilter: changeUserFilter,
                    placeFilter: changePlaceFilter,
                    missionFilter: changeMissionFilter
                )
            }
        }
        
    }
}


