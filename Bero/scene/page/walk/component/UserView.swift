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

struct UserView: PageComponent, Identifiable{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var pageObservable:PageObservable = PageObservable()
    let mission:Mission
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            if let user  = self.mission.user {
                HStack(alignment: .center, spacing:Dimen.margin.thin){
                    if let pet = user.representativePet {
                        PetProfileTopInfo(profile:pet, isSimple: true)
                            .frame(width:110)
                        
                    } else {
                        UserProfileTopInfo(profile: user.currentProfile, isSimple: true)
                            .frame(width:110)
                    }
                    
                    VStack(spacing:Dimen.margin.tiny){
                        FriendFunctionBox(user: user)
                        FillButton(
                            type: .stroke,
                            text: String.button.visitProfile,
                            color:  Color.brand.primary)
                        { _ in
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.user)
                                    .addParam(key: .data, value:user)
                            )
                            self.pagePresenter.closePopup(self.pageObservable.pageObject?.id)
                        }
                    }
                }
                .padding(.horizontal, Dimen.app.pageHorinzontal)
                .padding(.top, Dimen.margin.thin)
                
                //UsersDogSection( user:user , isSimple: true)
            }
        }
        .background(Color.app.white)
        
    }
    
}



#if DEBUG
struct UserView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            UserView(
                mission: Mission()
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
