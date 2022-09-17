//
//  ComponentTabNavigation.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct PlaceControl : PageComponent {
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
    var data:Place
    let close: (() -> Void)
    var body: some View {
        HStack(){
            PlaceProfileInfo(profile: data){
                self.appSceneObserver.event = .toast("장소페이지 이동?")
            }
            
            CircleButton(
                type: .icon(Asset.icon.human_friends),
                isSelected: false){ _ in
                    self.appSceneObserver.event = .toast("방문자보기?")
            }
            CircleButton(
                type: .icon(Asset.icon.checked_circle),
                isSelected: false){ _ in
                    self.appSceneObserver.event = .toast("흔적남기기?")
            }
        }
        
    }//body

}

#if DEBUG
struct PlaceControl_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlaceControl(
                data:.init()
            ){
                
            }
            .frame( alignment: .center)
        }
        .background(Color.app.white)
        .environmentObject(AppSceneObserver())
        .environmentObject(WalkManager(dataProvider: DataProvider(), locationObserver: LocationObserver()))
        .environmentObject(DataProvider())
    }
}
#endif
