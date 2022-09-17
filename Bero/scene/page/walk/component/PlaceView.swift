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

struct PlaceView: PageComponent, Identifiable{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    let id:String = UUID().uuidString
    let place:Place
    var body: some View {
        InfinityScrollView(
            viewModel: self.infinityScrollModel,
            axes: .vertical,
            scrollType: .vertical(isDragEnd: false),
            showIndicators : false,
            marginVertical: Dimen.margin.regular,
            marginHorizontal: 0,
            spacing:Dimen.margin.regularExtra,
            isRecycle: false,
            useTracking: true
        ){
            PlaceInfo(
                sortIconPath: self.place.place?.icon,
                sortTitle: self.walkManager.placeFilter.getTitle(type: .place),
                title: self.place.name,
                description: self.place.place?.vicinity,
                distance: self.distance)
                .padding(.horizontal, Dimen.app.pageHorinzontal)
            HStack(spacing:Dimen.margin.micro){
                RewardInfo(
                    type: .exp,
                    value: self.place.playExp.toInt()
                )
                RewardInfo(
                    type: .point,
                    value: self.place.playPoint
                )
                FillButton(
                    type: .fill,
                    text: String.button.leaveAmark,
                    size: Dimen.button.regular,
                    color:  Color.app.white,
                    gradient:Color.app.orangeGradient,
                    isActive: !self.isMark
                ){_ in
                    if self.isMark {
                        return
                    }
                    self.dataProvider.requestData(q: .init(type: .registVisit(self.place)))
                }
            }
            .padding(.horizontal, Dimen.app.pageHorinzontal)
            SelectButton(
                type: .small,
                icon: Asset.icon.beenhere,
                text: String.pageText.walkPlaceMarkText.replace(self.visitorNum.description),
                isSelected: false
            ){_ in
                
            }
            .padding(.horizontal, Dimen.app.pageHorinzontal)
        }
        .background(Color.app.white)
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .registVisit(let place) :
                if place.placeId == self.place.placeId {
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
    @State var visitorNum:Int = 0
    @State var distance:Double = 0
    private func onMark(){
        self.place.addMark(user: self.dataProvider.user)
        self.updateData()
    }
    
    private func updateData(){
        self.isMark = self.place.isMark
        self.visitorNum = self.place.visitors.count
        if let loc = self.walkManager.currentLocation, let destination = self.place.location {
            self.distance = destination.distance(from: loc)
        }
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
