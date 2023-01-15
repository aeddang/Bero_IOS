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
struct PageAddDogCompleted: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
     
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(alignment: .center, spacing: Dimen.margin.medium ){
                    Spacer()
                    VStack(alignment: .center, spacing: 0 ){
                        ZStack{
                            Image(Asset.image.profile_deco)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 136, height: 90)
                            ProfileImage(
                                id : self.id,
                                image: self.profile.image,
                                size: Dimen.profile.medium
                            )
                        }
                        HStack(spacing:Dimen.margin.tiny){
                            Text(String.pageText.addDogCompletedText1)
                                .modifier(RegularTextStyle(
                                    size: Font.size.thin,color: Color.app.grey500))
                            Image(Asset.icon.hi)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                        }
                        .padding(.vertical, Dimen.margin.regularExtra)
                        if let name = self.profile.name {
                            Text(name)
                                .modifier(BoldTextStyle(
                                    size: Font.size.black,color: Color.app.black))
                                .padding(.vertical, Dimen.margin.micro)
                        }
                        Text(String.pageText.addDogCompletedText2)
                            .modifier(RegularTextStyle(
                                size: Font.size.light,color: Color.app.black))
                            .multilineTextAlignment(.center)
                            .padding(.vertical, Dimen.margin.heavy)
                    }
                    Spacer()
                    FillButton(
                        type: .fill,
                        text: String.pageText.addDogCompletedConfirm,
                        color:Color.app.white,
                        gradient: Color.app.orangeGradient
                    ){_ in
                        self.regist()
                    }
                    .modifier(Shadow())
                }
                .padding(.bottom, Dimen.margin.thin)
                .modifier(PageAll())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                //.modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
        }//GeometryReader
        .onReceive(self.dataProvider.user.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .addedDog :
                self.pagePresenter.closePopup(self.pageObject?.id)
            default : break
            }
            
        }
        .onAppear{
            guard let obj = self.pageObject  else { return }
            guard let profile = obj.getParamValue(key: .data) as? ModifyPetProfileData else { return }
            self.profile = profile
             
        }
    }//body
    
    @State var profile:ModifyPetProfileData = ModifyPetProfileData(name: "test")
    
    private func regist(){
        guard let user = self.dataProvider.user.snsUser else { return }
        self.dataProvider.requestData(q: .init(
            id: self.tag,
            type: .registPet(user, self.profile, isRepresentative: self.dataProvider.user.representativePet == nil),
            isLock: true
            )
        )
    }
    
    
}


#if DEBUG
struct PageAddDogCompleted_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageAddDogCompleted().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(AppSceneObserver())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

