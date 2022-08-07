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
struct PageAddDog: PageView {
    enum Step: CaseIterable{
        case name, picture, gender, birth, breed, immun, tag, identify
        var description:String {
            switch self {
            case .name: return "What is the name of your dog?"
            case .picture : return "Select %s’s profile picture"
            case .gender : return "What is %s’s sex?"
            case .birth : return "When is %s’s birthday?"
            case .breed : return "What is %s’s breed?"
            case .immun : return "Health & Immunization"
            case .tag : return "Select all that applies to %s."
            case .identify : return "Identify %s."
            }
        }
        var caption:String? {
            switch self {
            case .birth : return "If you don’t know the exact birthday,\ninsert your best guess."
            default : return nil
            }
        }
        
        var placeHolder:String{
            switch self {
            case .name : return "ex. Bero"
            default : return ""
            }
        }
        
        var isFirst:Bool{
            switch self {
            case .name : return true
            default : return false
            }
        }
        
    }
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(alignment: .leading, spacing: Dimen.margin.medium ){
                    TitleTab(title: String.pageTitle.addDog, useBack: false, buttons:[.close]){ type in
                        switch type {
                        case .back :
                            self.onPrevStep()
                        case .close :
                            self.appSceneObserver.alert = .confirm("닫을래?", "정보사라짐"){ isOk in
                                if isOk {
                                    self.pagePresenter.goBack()
                                }
                            }
                        default : break
                        }
                    }
                    ProgressInfo(index: self.currentCount + 1, total: self.totalCount,
                                 image: self.profile.image,
                                 info: self.currentStep.description.replace(self.profile.name ?? ""),
                                 subInfo: self.currentStep.caption
                    )
                    .onTapGesture {
                        self.onNextStep()
                    }
                    switch self.currentStep {
                    case .name :
                        InputTextStep(
                            profile: self.profile,
                            step: self.currentStep,
                            prev: {self.onPrevStep()},
                            next: { data in self.onNextStep(updateProfile: data)})
                    case .picture :
                        SelectPictureStep(
                            profile: self.profile,
                            step: self.currentStep,
                            prev: {self.onPrevStep()},
                            next: { data in self.onNextStep(updateProfile: data)})
                    case .gender :
                        SelectGenderStep(
                            profile: self.profile,
                            step: self.currentStep,
                            prev: {self.onPrevStep()},
                            next: { data in self.onNextStep(updateProfile: data)})
                    case .birth :
                        SelectDateStep(
                            profile: self.profile,
                            step: self.currentStep,
                            prev: {self.onPrevStep()},
                            next: { data in self.onNextStep(updateProfile: data)})
                    default: Spacer()
                    }
                    
                }
                .modifier(PageAll())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
        }//GeometryReader
        .onAppear{
           
             
        }
    }//body
    
    @State var profile:ModifyPetProfileData = ModifyPetProfileData()
    @State var currentStep:Step = .name
    @State var currentCount:Int = 0
    let totalCount:Int = Self.Step.allCases.count
    private func onPrevStep(){
        let wiilStep = self.currentCount - 1
        if wiilStep < 0 {
            self.pagePresenter.goBack()
            return
        }
        self.currentCount = wiilStep
        withAnimation{
            self.currentStep = Self.Step.allCases[wiilStep]
        }
    }
    private func onNextStep(updateProfile:ModifyPetProfileData? = nil){
        if let update = updateProfile {
            self.profile = self.profile.updata(update)
        }
        let wiilStep = self.currentCount + 1
        if wiilStep == self.totalCount {
            self.onCompleted()
            return
        }
        self.currentCount = wiilStep
        withAnimation{
            self.currentStep = Self.Step.allCases[wiilStep]
        }
    }
    private func onCompleted(){
        
    }
}


#if DEBUG
struct PageAddDog_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageAddDog().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

