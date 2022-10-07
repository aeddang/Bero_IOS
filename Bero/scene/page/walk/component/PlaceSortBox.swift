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

struct PlaceSortBox: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
   
    var body: some View {
        HStack(spacing:Dimen.margin.thin){
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing:Dimen.margin.tiny){
                    PlaceSortButton(type: .vet, isSelect: self.$showVet){
                        withAnimation{
                            self.showVet.toggle()
                        }
                        self.onSort(type: .vet, isShow: self.showVet)
                    }
                   
                    PlaceSortButton(type: .restaurant, isSelect: self.$showRestaurant){
                        withAnimation{
                            self.showRestaurant.toggle()
                        }
                        self.onSort(type: .restaurant, isShow: self.showRestaurant)
                    }
                    
                    PlaceSortButton(type: .cafe, isSelect: self.$showCafe){
                        withAnimation{
                            self.showCafe.toggle()
                        }
                        self.onSort(type: .cafe, isShow: self.showCafe)
                    }
                    
                    PlaceSortButton(type: .petShop, isSelect: self.$showShop){
                        withAnimation{
                            self.showShop.toggle()
                        }
                        self.onSort(type: .petShop, isShow: self.showShop)
                    }
                    
                    CircleButton(
                        type: .icon(Asset.icon.refresh),
                        isSelected: false ,
                        strokeWidth: Dimen.stroke.regular,
                        activeColor: Color.brand.primary.opacity(0.5)
                    )
                    { _ in
                        guard let loc = self.walkManager.currentLocation else {return}
                        self.walkManager.resetMapPlace(loc)
                        self.pagePresenter.closePopup(pageId: .popupWalkPlace)
                    }
                }
                .padding(.horizontal, Dimen.app.pageHorinzontal)
            }
        }
        .opacity(self.isShow ? 1 : 0)
        .onReceive(self.viewModel.$componentHidden){ isHidden in
            withAnimation{ self.isShow = !isHidden }
        }
        .onAppear{
            self.showShop = self.walkManager.placeFilters.first(where: {$0 == .petShop}) != nil
            self.showCafe = self.walkManager.placeFilters.first(where: {$0 == .cafe}) != nil
            self.showRestaurant = self.walkManager.placeFilters.first(where: {$0 == .restaurant}) != nil
        }
    }//body
    @State var isShow:Bool = true
    @State var showShop:Bool = true
    @State var showCafe:Bool = true
    @State var showVet:Bool = true
    @State var showRestaurant:Bool = true
    
    private func onSort(type:WalkManager.Filter, isShow:Bool){
        guard let loc = self.walkManager.currentLocation else {return}
        self.walkManager.resetMapFilter(loc, placeFilter: type, use: isShow)
        self.pagePresenter.closePopup(pageId: .popupWalkPlace)
    }
}


struct PlaceSortButton: PageView {
    let type:WalkManager.Filter
    @Binding var isSelect:Bool
    let action: () -> Void
    var body: some View {
        SortButton(
            type: self.isSelect ? .fill : .stroke,
            sizeType: .big,
            icon: self.type.iconSort,
            iconType: .original,
            text: self.type.getTitle(type: .place),
            color: !self.isSelect ? Color.app.black : self.type.color,
            isSort: false,
            action: self.action
        )
    }//body
}
