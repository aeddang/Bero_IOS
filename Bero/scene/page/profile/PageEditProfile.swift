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
extension PageEditProfile{
    enum EditType: CaseIterable{
        case name, gender, birth, introduction, weight, height, immun, hash, animalId, microchip
        var title:String {
            switch self {
            case .name: return "Edit Name"
            case .gender : return "Edit Gender"
            case .birth : return "Edit Age"
            case .introduction : return "Edit Introduction"
            case .weight: return "Edit Weight"
            case .height: return "Edit Height"
            case .immun: return "Edit Immunization"
            case .hash: return "Edit Tags"
            case .animalId: return "Edit Animal ID"
            case .microchip: return "Edit microchip"
            }
        }
        
        var caption:String? {
            switch self {
            case .name : return String.app.name
            case .weight: return "Weight (lbs)"
            case .height: return "Height (feet)"
            case .birth : return "Select your birthday"
            case .immun: return "Select all that applies"
            case .animalId: return String.app.animalId
            case .microchip: return String.app.microchip
            default : return nil
            }
        }
        
        var placeHolder:String{
            switch self {
            case .name : return "ex. Bero"
            case .animalId : return "ex) 123456789012345"
            case .microchip : return "ex) 123456789"
            default : return ""
            }
        }
        
        var keyboardType:UIKeyboardType {
            switch self {
            case .microchip, .animalId : return .numberPad
            case .weight, .height : return .decimalPad
            default : return .namePhonePad
            }
        }
    }
    struct EditData {
        var name:String? = nil
        var gender:Gender? = nil
        var birth:Date? = nil
        var introduction:String? = nil
        var microchip:String? = nil
        var animalId:String? = nil
        var immunStatus:String? = nil
        var hashStatus:String? = nil
        var weight:Double? = nil
        var size:Double? = nil
    }
}



struct PageEditProfile: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
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
                VStack(alignment: .leading, spacing: Dimen.margin.medium ){
                    TitleTab(
                        type:.section,
                        title: self.currentType?.title ?? "",
                        alignment: .center,
                        useBack: true)
                    { type in
                        switch type {
                        case .back :
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        default : break
                        }
                    }
                    if let type = self.currentType {
                        switch type {
                        case .name :
                            InputTextEdit(
                                prevData: self.name,
                                type: type){data in
                                    self.onEdit(data: data)
                                }
                        case .microchip :
                            InputTextEdit(
                                prevData: self.microchip,
                                type: type){data in
                                    self.onEdit(data: data)
                                }
                        case .animalId :
                            InputTextEdit(
                                prevData: self.animalId,
                                type: type){data in
                                    self.onEdit(data: data)
                                }
                        case .weight :
                            InputTextEdit(
                                prevData: self.weight,
                                type: type){data in
                                    self.onEdit(data: data)
                                }
                        case .height :
                            InputTextEdit(
                                prevData: self.height,
                                type: type){data in
                                    self.onEdit(data: data)
                                }
                        case .gender :
                            SelectGenderEdit(
                                prevData: self.gender,
                                type: type){data in
                                    self.onEdit(data: data)
                                }
                        case .birth :
                            SelectDateEdit(
                                prevData: self.birth,
                                type: type){data in
                                    self.onEdit(data: data)
                                }
                        case .introduction :
                            InputTextEdit(
                                prevData: self.introduction,
                                type: type){data in
                                    self.onEdit(data: data)
                                }
                        case .immun :
                            SelectListEdit(
                                infinityScrollModel: self.infinityScrollModel,
                                prevData: self.immunStatus,
                                type: type){data in
                                    self.onEdit(data: data)
                                }
                        case .hash :
                            SelectTagEdit(
                                prevData: self.hashStatus,
                                type: type){data in
                                    self.onEdit(data: data)
                                }
                        }
                    
                    } else {
                        Spacer().modifier(MatchParent())
                    }
                }
                .modifier(PageAll())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
        }//GeometryReader
        .onAppear{
            guard let obj = self.pageObject  else { return }
            if let profile = obj.getParamValue(key: .data) as? PetProfile{
                self.profile = profile
                self.name = profile.name ?? ""
                self.birth = profile.birth ?? Date()
                self.gender = profile.gender ?? .male 
                self.introduction = profile.introduction ?? ""
                self.weight = profile.weight?.description ?? ""
                self.height = profile.size?.description ?? ""
                self.immunStatus = profile.immunStatus ?? ""
                self.hashStatus = profile.hashStatus ?? ""
                self.microchip = profile.microchip ?? ""
                self.animalId = profile.animalId ?? ""
            }
            if let user = obj.getParamValue(key: .data) as? User{
                self.user = user
                self.name = user.currentProfile.nickName ?? ""
                self.birth = user.currentProfile.birth ?? Date()
                self.gender = user.currentProfile.gender ?? .male
                self.introduction = user.currentProfile.introduction ?? ""
            }
            if let type = obj.getParamValue(key: .type) as?  PageEditProfile.EditType{
                self.currentType = type
            }
        }
    }//body
    @State var user:User? = nil
    @State var profile:PetProfile? = nil
    @State var currentType:EditType? = nil
    @State var name:String = ""
    @State var weight:String = ""
    @State var height:String = ""
    @State var birth:Date = Date()
    @State var gender:Gender? = nil
    @State var introduction:String = ""
    @State var immunStatus:String = ""
    @State var hashStatus:String = ""
    @State var microchip:String = ""
    @State var animalId:String = ""
    private func onEdit(data:EditData){
        if let user = self.user, let snsUser = user.snsUser {
            let modifyData = ModifyUserProfileData(
                nickName: data.name,
                gender: data.gender,
                birth: data.birth,
                introduction: data.introduction
            )
            self.dataProvider.requestData(q: .init(
                type: .updateUser(snsUser, modifyData)))
            
        } else if let pet = self.profile {
            let modifyData = ModifyPetProfileData(
                name: data.name,
                gender: data.gender,
                birth: data.birth,
                microchip: data.microchip,
                animalId: data.animalId,
                immunStatus: data.immunStatus,
                hashStatus: data.hashStatus,
                introduction: data.introduction,
                weight: data.weight,
                size: data.size
            )
            self.dataProvider.requestData(q: .init(
                type: .updatePet(petId:pet.petId, modifyData)))
        }
        self.pagePresenter.closePopup(self.pageObject?.id)
    }
}


#if DEBUG
struct PageEditProfile_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageEditProfile().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

