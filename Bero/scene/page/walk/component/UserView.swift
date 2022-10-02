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
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var geometry:GeometryProxy? = nil
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    let id:String = UUID().uuidString
    let mission:Mission
    var location:CLLocation? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.infinityScrollModel,
            axes: .vertical,
            scrollType: .vertical(isDragEnd: false),
            showIndicators : false,
            marginVertical: Dimen.margin.medium,
            marginHorizontal: 0,
            spacing:Dimen.margin.regularExtra,
            isRecycle: false,
            useTracking: true
        ){
            if let user  = self.mission.user {
                HStack(alignment: .center, spacing:Dimen.margin.thin){
                    UserProfileTopInfo(profile: user.currentProfile, isSimple: true)
                        .frame(width:110)
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
                
                UsersDogSection( user:user , isSimple: true)
                
            }
            if let path = self.mission.pictureUrl {
                ImageView(url: path,
                          contentMode: .fill,
                          noImg: Asset.noImg16_9)
                .modifier(Ratio16_9(geometry: self.geometry, horizontalEdges: Dimen.app.pageHorinzontal))
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
                .padding(.horizontal, Dimen.app.pageHorinzontal)
                
            }
        }
        .background(Color.app.white)
        .modifier(
            ContentScrollPull(
                infinityScrollModel: self.infinityScrollModel,
                pageDragingModel: self.pageDragingModel)
        )
    }
    
}



#if DEBUG
struct UserView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            UserView(
                mission:Mission()
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
