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

struct PlaceView: PageComponent{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var pageObservable:PageObservable = PageObservable()
    let place:Place
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            PlaceInfo(
                pageObservable: self.pageObservable,
                sortIconPath: self.place.place?.icon,
                sortTitle: self.place.sortType?.getTitle(type: .place),
                title: self.place.title,
                description: self.place.place?.vicinity,
                distance: self.distance,
                action: {
                    self.walkManager.viewRoute(place: self.place)
                }
            )
            .padding(.horizontal, Dimen.app.pageHorinzontal)
            .padding(.top, Dimen.margin.regular)
            HStack(spacing:Dimen.margin.micro){
                /*
                RewardInfo(
                    type: .exp,
                    value: self.place.playExp.toInt()
                )
                RewardInfo(
                    type: .point,
                    value: self.place.playPoint
                )*/
                FillButton(
                    type: .fill,
                    icon: Asset.icon.pin_drop,
                    text: String.button.leaveAmark,
                    size: Dimen.button.regular,
                    color:  Color.app.white,
                    gradient:Color.app.orangeGradient,
                    isActive: !self.isMark
                ){_ in
                    if self.isMark {
                        return
                    }
                    self.updateData()
                    if self.distance > WalkManager.nearDistance {
                        self.appSceneObserver.sheet = .alert(
                            String.pageText.walkPlaceMarkDisAbleTitle,
                            String.pageText.walkPlaceMarkDisAbleText
                        )
                        return
                    }
                    
                    self.dataProvider.requestData(q: .init(type: .registVisit(self.place)))
                }
                if SystemEnvironment.isTestMode {
                    if !self.isMark {
                        FillButton(
                            type: .fill,
                            text:"완료 테스트용",
                            size: Dimen.button.regular
                        ){ _ in
                            self.dataProvider.requestData(q: .init(type: .registVisit(self.place)))
                        }
                    }
                }
            }
            .padding(.horizontal, Dimen.app.pageHorinzontal)
            
            if self.visitors.isEmpty {
                SelectButton(
                    type: .small,
                    icon: Asset.icon.beenhere,
                    text: String.pageText.walkPlaceNoMarkText,
                    isSelected: false
                ){_ in
                    /*
                    self.pagePresenter.openPopup(PageProvider.getPageObject(.popupPlaceVisitor).addParam(key: .data, value: self.place))
                    */
                }
                .opacity(0.4)
                .padding(.horizontal, Dimen.app.pageHorinzontal)
            } else {
                VisitorHorizontalView(
                    pageObservable: self.pageObservable,
                    place: self.place,
                    datas: self.visitors
                )
            }
            
        }
        .background(Color.app.white)
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .registVisit(let place) :
                if place.googlePlaceId == self.place.googlePlaceId {
                    self.onMark()
                }
            default : break
            }
        }
        .onAppear{
            self.updateData()
        }
    }
    
    @State var isMark:Bool = false
    @State var visitors: [MultiProfileListItemData] = []
    @State var distance:Double = 0
    private func onMark(){
        self.place.addMark(user: self.dataProvider.user)
        self.updateData()
        self.walkManager.registPlace()
    }
    
    private func updateData(){
        self.isMark = self.place.isMark
        if let loc = self.walkManager.currentLocation, let destination = self.place.location {
            self.distance = destination.distance(from: loc)
        }
        self.visitors = self.place.visitors.map{MultiProfileListItemData().setData($0, idx: -1)}
    }
}


/*
#if DEBUG
struct PlaceView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlaceView(
                place: Place()
            )
        }
        .padding(.all, 10)
        .background(Color.app.white)
        .environmentObject(PagePresenter())
        .environmentObject(PageSceneObserver())
        .environmentObject(Repository())
        .environmentObject(DataProvider())
        .environmentObject(AppSceneObserver())
    }
}
#endif
*/
