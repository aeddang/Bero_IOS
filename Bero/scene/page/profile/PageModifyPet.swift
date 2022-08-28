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
struct PageModifyPet: PageView {
    
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
                        type:.section,
                        title: String.pageTitle.dogProfile,
                        alignment: .center,
                        useBack: true){ type in
                        switch type {
                        case .back : self.pagePresenter.closePopup(self.pageObject?.id)
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
                        spacing:Dimen.margin.medium,
                        isRecycle: false,
                        useTracking: false
                    ){
                        if let profile = self.profile{
                            PetProfilePictureEdit(
                                profile: profile
                            )
                            PetProfileEdit(
                                profile: profile
                            )
                        }
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let profile = obj.getParamValue(key: .data) as? PetProfile{
                    self.profile = profile
                }
            }
        }//GeometryReader
       
    }//body
    @State var profile:PetProfile? = nil
   
}


#if DEBUG
struct PageModifyPet_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageModifyPet().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

