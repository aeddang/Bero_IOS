//
//  ProfilePictureEdit.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/27.
//

import Foundation
import SwiftUI
struct UserProfileEdit: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var profile:UserProfile
    var user:SnsUser? = nil
    @State var name:String = ""
    @State var gender:String = ""
    @State var age:String = ""
    @State var introduction:String = ""
   
    var body: some View {
        VStack(spacing:Dimen.margin.regular){
            SelectButton(
                type: .medium,
                title: String.app.name,
                text: self.name,
                useStroke: false,
                useMargin: false
            ){_ in
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.editProfile)
                        .addParam(key: .data, value: self.dataProvider.user)
                        .addParam(key: .type, value: PageEditProfile.EditType.name)
                )
            }
            Spacer().modifier(LineHorizontal())
            SelectButton(
                type: .medium,
                title: String.app.gender,
                text: self.gender,
                useStroke: false,
                useMargin: false
            ){_ in
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.editProfile)
                        .addParam(key: .data, value: self.dataProvider.user)
                        .addParam(key: .type, value: PageEditProfile.EditType.gender)
                )
            }
            Spacer().modifier(LineHorizontal())
            SelectButton(
                type: .medium,
                title: String.app.age,
                text: self.age,
                useStroke: false,
                useMargin: false
            ){_ in
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.editProfile)
                        .addParam(key: .data, value: self.dataProvider.user)
                        .addParam(key: .type, value: PageEditProfile.EditType.birth)
                )
            }
            Spacer().modifier(LineHorizontal())
            SelectButton(
                type: .medium,
                title: String.app.introduction,
                text: self.introduction,
                useStroke: false,
                useMargin: false
            ){_ in
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.editProfile)
                        .addParam(key: .data, value: self.dataProvider.user)
                        .addParam(key: .type, value: PageEditProfile.EditType.introduction)
                )
            }
        }
        .onReceive(self.profile.$nickName){ value in
            self.name = value ?? ""
        }
        .onReceive(self.profile.$gender){ value in
            self.gender = value?.title ?? ""
        }
        .onReceive(self.profile.$birth){ value in
            self.age = value?.toAge() ?? ""
        }
        .onReceive(self.profile.$introduction){ value in
            self.introduction = value ?? ""
        }
    }
    
}


