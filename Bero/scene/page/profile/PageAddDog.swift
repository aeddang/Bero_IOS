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

extension PageAddDog{
    enum Step: CaseIterable{
        //case name, picture, gender, birth, breed, immun, hash, identify
        case name, picture, gender, birth, breed, hash
        var description:String {
            switch self {
            case .name: return "Tell us your beloved dog's name!"
            case .picture : return "Select your favorite photo of %s!"
            case .gender : return "What is %s’s gender?"
            case .birth : return "When is %s’s birthday?"
            case .breed : return "Find %s’s breed!"
            //case .immun : return "Health & Immunization"
            case .hash : return "Share %s’s Personality."
            //case .identify : return "Identify %s."
            }
        }
        var caption:String? {
            switch self {
            case .birth : return "If you don’t know the exact birthday put your best guess."
            case .hash : return "Choose all the tags that related with %s."
            default : return nil
            }
        }
        var inputType:[String]? {
            switch self {
           //case .identify : return [String.app.animalId, String.app.microchip]
            default : return nil
            }
        }
        var inputDescription:String? {
            switch self {
            //case .identify : return "An animal ID is consisted of 15 digits.\nTake your pet to be scanned at the local vet, rescue centre or dog wardens service."
            default : return nil
            }
        }
        var keyboardType:UIKeyboardType {
            switch self {
            //case .identify: return .numberPad
            default : return .namePhonePad
            }
        }
        var limitedTextLength:Int {
            switch self {
            case .name : return 20
            default : return 100
            }
        }
        
        var autocapitalizationType: UITextAutocapitalizationType{
            switch self {
            case .name : return .allCharacters
            default : return .words
            }
        }
        var placeHolder:String{
            switch self {
            case .name : return "ex. Bero"
            //case .identify : return "ex) 123456789"
            case .breed : return "Search breed"
            default : return ""
            }
        }
        
        var isFirst:Bool{
            switch self {
            case .name : return true
            default : return false
            }
        }
        
        var isSkipAble:Bool{
            switch self {
            //case .identify : return true
            default : return false
            }
        }
    }
}

struct PageAddDog: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
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
                VStack(alignment: .leading, spacing: Dimen.margin.medium ){
                    TitleTab(
                        infinityScrollModel: self.infinityScrollModel,
                        title: String.pageTitle.addDog,
                        alignment: .center,
                        margin: 0,
                        buttons:[.close])
                    { type in
                        switch type {
                        case .close :
                            self.appSceneObserver.alert = .confirm(
                                String.alert.closeConfirm,
                                String.alert.closeConfirmText){ isOk in
                                    
                                if isOk {
                                    self.pagePresenter.goBack()
                                }
                            }
                        default : break
                        }
                    }
                    StepInfo(index: self.currentCount + 1, total: self.totalCount,
                                 image: self.profile.image,
                                 info: self.currentStep.description.replace(self.profile.name ?? ""),
                                 subInfo: self.currentStep.caption?.replace(self.profile.name ?? "")
                    )
                
                    switch self.currentStep {
                    case .name : //, .identify :
                        InputTextStep(
                            navigationModel: self.navigationModel,
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
                    /*
                    case .immun :
                        SelectListStep(
                            infinityScrollModel : self.infinityScrollModel,
                            profile: self.profile,
                            step: self.currentStep,
                            prev: {self.onPrevStep()},
                            next: { data in self.onNextStep(updateProfile: data)})
                    */
                    case .breed :
                        SelectListStep(
                            infinityScrollModel : self.infinityScrollModel,
                            profile: self.profile,
                            step: self.currentStep,
                            prev: {self.onPrevStep()},
                            next: { data in self.onNextStep(updateProfile: data)})
                    case .hash :
                        SelectTagStep(
                            profile: self.profile,
                            step: self.currentStep,
                            prev: {self.onPrevStep()},
                            next: { data in self.onNextStep(updateProfile: data)})
                   
                    }
                    
                }
                .padding(.bottom, self.bottomMargin)
                .onReceive(self.sceneObserver.$safeAreaBottom){ bottom in
                    withAnimation{self.bottomMargin = bottom + Dimen.margin.thin }
                }
                .modifier(PageTop())
                .modifier(PageHorizontal())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
        }//GeometryReader
        
        .onAppear{
           
             
        }
    }//body
    @State var bottomMargin:CGFloat = 0
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
        self.currentStep = Self.Step.allCases[wiilStep]
        
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
        self.currentStep = Self.Step.allCases[wiilStep]
    }
    private func onCompleted(){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.addDogCompleted)
                .addParam(key: .data, value: self.profile)
        )
        self.pagePresenter.closePopup(self.pageObject?.id)
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

