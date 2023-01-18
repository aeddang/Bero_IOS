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

struct UsersView: PageComponent, Identifiable{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var pageObservable:PageObservable = PageObservable()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
   
    var body: some View {
        VStack(spacing:0){
            MenuTab(
                viewModel:self.navigationModel,
                buttons: [
                    String.sort.all , String.sort.friends
                ],
                selectedIdx: self.isFriend ? 1 : 0
            )
            .padding(.horizontal, Dimen.app.pageHorinzontal)
            ZStack(alignment: .top){
                DragDownArrow(
                    infinityScrollModel: self.infinityScrollModel,
                    text: String.button.close)
                .padding(.top, Dimen.margin.regular)
                InfinityScrollView(
                    viewModel: self.infinityScrollModel,
                    axes: .vertical,
                    showIndicators : true,
                    marginVertical: Dimen.margin.medium,
                    marginHorizontal: Dimen.app.pageHorinzontal,
                    spacing:Dimen.margin.regularExtra,
                    isRecycle: true,
                    useTracking: true
                ){
                    if !self.isFriend {
                        Text(String.pageText.recommandUser)
                            .modifier(SemiBoldTextStyle(
                                size: Font.size.regular,
                                color: Color.app.black
                            ))
                        if self.recommandDatas.isEmpty {
                            EmptyData(
                                text: String.pageText.needTag
                            )
                        } else {
                            ForEach(self.recommandDatas) { data in
                                PetProfileUser(profile: data, friendStatus: .norelation){
                                    self.pagePresenter.openPopup(
                                        PageProvider.getPageObject(.user).addParam(key: .id, value:data.userId)
                                    )
                                }
                            }
                        }
                        Text(String.pageText.aroundUser)
                            .modifier(SemiBoldTextStyle(
                                size: Font.size.regular,
                                color: Color.app.black
                            ))
                        if self.datas.isEmpty {
                            EmptyItem(type: .myList)
                        } else {
                            ForEach(self.datas) { data in
                                PetProfileUser(profile: data.petProfile!, friendStatus: .norelation){
                                    self.pagePresenter.closePopup(self.pageObject?.id)
                                    self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkUser).addParam(key: .data, value: data))
                                }
                            }
                        }
                        
                    } else {
                        if self.datas.isEmpty {
                            EmptyItem(type: .myList)
                        } else {
                            ForEach(self.datas) { data in
                                PetProfileUser(profile: data.petProfile!, friendStatus: .chat){
                                    self.pagePresenter.closePopup(self.pageObject?.id)
                                    self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkUser).addParam(key: .data, value: data))
                                }
                            }
                        }
                    }
                }
            }
        }
        .onReceive(self.navigationModel.$index){ idx in
            self.isFriend = idx == 1 
            self.setupDatas()
        }
        .onAppear(){
            self.setupDatas()
        }
    }
    @State var recommandDatas:[PetProfile] = []
    @State var datas:[Mission] = []
    @State var isFriend:Bool = false
    private func setupDatas(){
        if self.isFriend {
            self.recommandDatas = []
            self.datas = self.walkManager.missionUsers.filter{$0.petProfile != nil}.filter{$0.isFriend}.map{$0}
        } else {
            self.recommandDatas = self.walkManager.missionUsers.filter{$0.petProfile != nil}.filter{$0.isFriend}.map{$0.petProfile!}
            self.datas = self.walkManager.missionUsers.filter{$0.petProfile != nil}.filter{!$0.isFriend}.map{$0}
        }
    }
    
    
}


#if DEBUG
struct UsersView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            UsersView(
            )
        }
        .padding(.all, 10)
        .background(Color.app.white)
        .environmentObject(PagePresenter())
        .environmentObject(PageSceneObserver())
        .environmentObject(Repository())
        .environmentObject(DataProvider())
        .environmentObject(AppSceneObserver())
        //.environmentObject(WalkManager())
    }
}
#endif
