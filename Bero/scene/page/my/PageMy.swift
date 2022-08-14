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
struct PageMy: PageView {
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(alignment: .leading, spacing: 0 ){
                    TitleTab(
                        title: String.pageTitle.my,
                        buttons:[.alram,.setting]){ type in
                        switch type {
                        case .alram : break
                        case .setting :
                            self.dataProvider.user.currentProfile.update(image: UIImage(named: Asset.image.manWithDog))
                            break
                        default : break
                        }
                    }
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        axes: .vertical,
                        showIndicators : false,
                        marginVertical: Dimen.margin.medium,
                        marginHorizontal: Dimen.app.pageHorinzontal,
                        spacing:0,
                        isRecycle: true,
                        useTracking: false
                    ){
                        UserProfileInfo(profile: self.dataProvider.user.currentProfile){
                            
                        }
                        
                        MyLevelSection()
                            .padding(.top, Dimen.margin.regularUltra)
                        MyDogsSection()
                            .padding(.top, Dimen.margin.medium)
                    }
                    /*
                    TitleTab(type:.menu, title: String.pageText.myLv, buttons:[.viewMore])
                    { type in
                        switch type {
                        case .viewMore : break
                        default : break
                        }
                    }
                    
                    TitleTab(type:.menu, title: String.pageText.myDogs, buttons:[.manageDogs])
                    { type in
                        switch type {
                        case .viewMore : break
                        default : break
                        }
                    }
                    
                    TitleTab(type:.menu, title: String.pageText.myHistory)
                    { type in
                        switch type {
                        case .viewMore : break
                        default : break
                        }
                    }*/
                    
                }
                .padding(.bottom, Dimen.app.bottom)
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            
            .onReceive(self.dataProvider.user.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .addedDog : break
                default : break
                }
                
            }
            .onAppear{
               
            
            }
        }//GeometryReader
       
    }//body
    
    @State var profile:UserProfile? = nil
    @State var profiles:[PetProfile] = []
    @State var point:Int = 0
    private func updatedUserInfo(){
        let user = self.dataProvider.user
        self.profile = user.currentProfile
        self.profiles = user.pets
    }
    
   
}


#if DEBUG
struct PageMy_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMy().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

