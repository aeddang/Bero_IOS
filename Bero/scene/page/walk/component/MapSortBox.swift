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
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
   
    var body: some View {
        HStack(spacing:Dimen.margin.tinyExtra){
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
        .onAppear{
            self.userFilter = self.walkManager.userFilter
            self.placeFilter = self.walkManager.placeFilter
            self.missionFilter = self.walkManager.missionFilter
        }
    }//body
   
    @State var userFilter:WalkManager.Filter = .all
    @State var placeFilter:WalkManager.Filter = .shop
    @State var missionFilter:WalkManager.Filter = .all
    
    private func onSort(_ type:WalkManager.SortType){
        let datas:[String] = type.filter.map{$0.getText(type: type)}
        self.appSceneObserver.radio = .sort((self.tag, datas)){ idx in
            guard let idx = idx else {return}
            switch type {
            case .user :
                self.userFilter = type.filter[idx]
            case .mission :
                self.missionFilter = type.filter[idx]
            case .place :
                self.placeFilter = type.filter[idx]
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                guard let loc = self.walkManager.currentLocation else {return}
                self.walkManager.resetMapStatus(
                    loc,
                    userFilter: self.userFilter,
                    placeFilter: self.placeFilter,
                    missionFilter: self.missionFilter
                )
            }
        }
        
    }
}


