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
    var geometry:GeometryProxy? = nil
    let mission:Mission
    var body: some View {
        ZStack(){
            if let profile = self.profile {
                VStack(alignment: .center, spacing:Dimen.margin.regularExtra){
                    PetProfileTopInfo(
                        profile: profile,
                        isHorizontal: true,
                        action: {
                            self.moveUser(id: self.mission.userId)
                        }
                    )
                    PetTagSection(
                        profile: profile,
                        title: nil,
                        listSize: (geometry?.size.width ?? 320) - (Dimen.app.pageHorinzontal*2)
                    )
                }
                .padding(.horizontal, Dimen.app.pageHorinzontal)
                .padding(.top, Dimen.margin.thin)
                //UsersDogSection( user:user , isSimple: true)
            } 
        }
        .background(Color.app.white)
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getPets(let userId, _) :
                if userId == self.mission.userId , let datas = res.data as? [PetData]{
                    if let data = datas.first(where: {$0.isRepresentative == true}) ?? datas.first {
                        let profile = PetProfile(data: data, userId: userId)
                        self.mission.petProfile = profile
                        self.profile = profile
                        self.pageObservable.isInit = true
                    }
                }
            default : break
            }
        }
        .onAppear(){
            self.profile = self.mission.petProfile
            if self.profile == nil {
                self.getProfile()
                return
            }
            self.pageObservable.isInit = true
        }
    }
    
    @State var profile:PetProfile? = nil
    private func getProfile(){
        if let id = self.mission.userId {
            self.dataProvider.requestData(q: .init(id:self.tag, type: .getPets(userId: id)))
        }
    }
    private func moveUser(id:String? = nil){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.user)
                .addParam(key: .id, value:id)
        )
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
