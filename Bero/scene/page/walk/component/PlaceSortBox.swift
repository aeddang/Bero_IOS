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
            CircleButton(
                type: .icon(WalkManager.Filter.petShop.iconSort),
                isSelected: self.showShop,
                activeColor: WalkManager.Filter.petShop.color
            )
            { _ in
                withAnimation{
                    self.showShop.toggle()
                }
                self.onSort(type: .petShop, isShow: self.showShop)
            }
            CircleButton(
                type: .icon(WalkManager.Filter.cafe.iconSort),
                isSelected: self.showCafe,
                activeColor: WalkManager.Filter.cafe.color
            )
            { _ in
                withAnimation{
                    self.showCafe.toggle()
                }
                self.onSort(type: .cafe, isShow: self.showCafe)
            }
            CircleButton(
                type: .icon(WalkManager.Filter.restaurant.iconSort),
                isSelected: self.showRestaurant,
                activeColor: WalkManager.Filter.restaurant.color
            )
            { _ in
                withAnimation{
                    self.showRestaurant.toggle()
                }
                self.onSort(type: .restaurant, isShow: self.showRestaurant)
            }
                    
        }
        .onAppear{
            self.showShop = self.walkManager.placeFilters.first(where: {$0 == .petShop}) != nil
            self.showCafe = self.walkManager.placeFilters.first(where: {$0 == .cafe}) != nil
            self.showRestaurant = self.walkManager.placeFilters.first(where: {$0 == .restaurant}) != nil
        }
    }//body
  
    @State var showShop:Bool = true
    @State var showCafe:Bool = true
    @State var showRestaurant:Bool = true
    
    private func onSort(type:WalkManager.Filter, isShow:Bool){
        guard let loc = self.walkManager.currentLocation else {return}
        self.walkManager.resetMapFilter(loc, placeFilter: type, use: isShow)
    }
}


