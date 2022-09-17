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

struct UserControl : PageComponent {
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
    var data:Mission
    let close: (() -> Void)
    var body: some View {
        HStack(){
            if let profile = data.user?.currentProfile {
                UserProfileInfo(profile: profile){
                    self.appSceneObserver.event = .toast("프로필페이지 이동?")
                }
            }
            CircleButton(
                type: .icon(Asset.icon.add_friend),
                isSelected: false){ _ in
                    self.appSceneObserver.event = .toast("친구요청?")
                      
            }
        }
        
    }//body

}

#if DEBUG
struct UserControl_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            UserControl(
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
