//
//  PageTest.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import Combine
import Firebase
import FacebookLogin
import FirebaseCore
import GoogleSignInSwift
struct PageManageDogs: PageView {
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(alignment: .leading, spacing: 0 ){
                    TitleTab(
                        infinityScrollModel: self.infinityScrollModel,
                        useBack: true
                    ){ type in
                        switch type {
                        case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                        default : break
                        }
                    }
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        axes: .vertical,
                        showIndicators : false,
                        marginVertical: Dimen.margin.medium,
                        marginHorizontal: Dimen.app.pageHorinzontal,
                        spacing:Dimen.margin.regularExtra,
                        isRecycle: false,
                        useTracking: true
                    ){
                        
                        TitleSection(
                            title: String.button.manageDogs
                        )
                        
                        ForEach(self.pets) { pet in
                            PetProfileEditable(profile: pet){
                                self.deletePet(pet)
                            }
                            .onTapGesture {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.dog)
                                        .addParam(key: .data, value: pet)
                                )
                            }
                        }
                        if self.pets.count < 3 {
                            PetProfileEmpty(
                                description: self.pets.isEmpty ? String.pageText.addDogEmpty : nil
                            ){
                                self.pagePresenter.openPopup(PageProvider.getPageObject(.addDog))
                            }
                        }
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.dataProvider.user.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .addedDog, .deletedDog: self.update()
                default : break
                }
            }
            .onAppear(){
                self.update()
            }
        }//GeometryReader
       
    }//body
    @State var pets:[PetProfile] = []
    
    private func update(){
        self.pets = self.dataProvider.user.pets
    }
    
    private func deletePet(_ profile:PetProfile){
        if walkManager.status == .walking {
            self.appSceneObserver.event = .toast(String.alert.walkDisableRemovePet)
            return
        }
        
        self.appSceneObserver.sheet = .select(
            String.alert.deleteDogTitle,
            String.alert.deleteDogText,
            [String.app.cancel,String.alert.deleteDogConfirm]){ idx in
                if idx == 1 {
                    self.dataProvider.requestData(q: .init(type: .deletePet(petId: profile.petId)))
                }
        }
    }
}


#if DEBUG
struct PageManageDogs_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageManageDogs().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(DataProvider())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

