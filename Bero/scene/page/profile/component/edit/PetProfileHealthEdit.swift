//
//  ProfilePictureEdit.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/27.
//

import Foundation
import SwiftUI
struct PetProfileHealthEdit: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var profile:PetProfile

    @State var weight:String = "-"
    @State var height:String = "-"
    @State var immunization:String = "-"
    @State var animalId:String = String.button.unregistered
    @State var microchip:String = String.button.unregistered
   
    var body: some View {
        VStack(spacing:Dimen.margin.regular){
            SelectButton(
                type: .medium,
                title: String.app.weight,
                text: self.weight,
                useStroke: false
            ){_ in
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.editProfile)
                        .addParam(key: .data, value: self.profile)
                        .addParam(key: .type, value: PageEditProfile.EditType.weight)
                )
            }
            Spacer().modifier(LineHorizontal())
            SelectButton(
                type: .medium,
                title: String.app.height,
                text: self.height,
                useStroke: false
            ){_ in
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.editProfile)
                        .addParam(key: .data, value:self.profile)
                        .addParam(key: .type, value: PageEditProfile.EditType.height)
                )
            }
            Spacer().modifier(LineHorizontal())
            SelectButton(
                type: .medium,
                title: String.app.immunization,
                text: self.immunization,
                useStroke: false
            ){_ in
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.editProfile)
                        .addParam(key: .data, value: self.profile)
                        .addParam(key: .type, value: PageEditProfile.EditType.immun)
                )
            }
            Spacer().modifier(LineHorizontal())
            SelectButton(
                type: .medium,
                title: String.app.animalId,
                text: self.animalId,
                useStroke: false
            ){_ in
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.editProfile)
                        .addParam(key: .data, value: self.profile)
                        .addParam(key: .type, value: PageEditProfile.EditType.animalId)
                )
            }
            Spacer().modifier(LineHorizontal())
            SelectButton(
                type: .medium,
                title: String.app.microchip,
                text: self.microchip,
                useStroke: false
            ){_ in
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.editProfile)
                        .addParam(key: .data, value: self.profile)
                        .addParam(key: .type, value: PageEditProfile.EditType.microchip)
                )
            }
        }
        .onReceive(self.profile.$weight){ weight in
            guard let w = weight else {return}
            self.weight = w.description + String.app.kg
        }
        .onReceive(self.profile.$size){ size in
            guard let h = size else {return}
            self.height = h.description + String.app.cm
        }
        .onReceive(self.profile.$immunStatus){ immunStatus in
            guard let status = immunStatus else {return}
            self.immunStatus = status
            self.setupImmunStatus()
        }
        .onReceive(self.profile.$microchip){ microchip in
            guard let chip = microchip else {return}
            self.microchip = chip
        }
        .onReceive(self.profile.$animalId){ animalId in
            guard let id = animalId else {return}
            self.animalId = id
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getCode(let category,_):
                self.setupCode(res, category: category)
            default : break
            }
        }
        .onAppear(){
            self.dataProvider.requestData(q: .init(id: self.tag, type: .getCode(category: .status)))
        }
    }
    @State var immunStatus:String = ""
    @State var immunStrigs:[String:String] = [:]
    private func setupCode(_ res:ApiResultResponds,  category:MiscApi.Category){
        guard let datas = res.data as? [CodeData] else { return }
        if category != .status {return}
        datas.forEach{ data in
            if let id = data.id?.description, let value = data.value {
                self.immunStrigs[id] = value
            }
        }
        self.setupImmunStatus()
    }
    private func setupImmunStatus(){
        let keys = PetProfile.exchangeStringToList(self.immunStatus)
        if keys.isEmpty {
            self.immunization = "-"
            return
        }
        var strs:[String] = []
        keys.forEach{ key in
            if let str =  self.immunStrigs[key] {
                strs.append(str)
            }
        }
        self.immunization = PetProfile.exchangeListToString(strs)
    }
}


