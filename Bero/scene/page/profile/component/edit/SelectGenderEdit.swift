//
//  TitleTab.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/20.
//

//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI

struct SelectGenderEdit: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    var prevData:Gender? = nil
    let type:PageEditProfile.EditType
    var needAgree:Bool = false
    let edit: ((PageEditProfile.EditData) -> Void)
    @State var selectGender:Gender? = nil
    @State var isAgree:Bool = true
    var body: some View {
        VStack(spacing: Dimen.margin.heavy){
            HStack(spacing:Dimen.margin.tinyExtra){
                RectButton(
                    icon: Gender.male.icon,
                    text: Gender.male.title,
                    isSelected: self.selectGender == Gender.male,
                    color: Gender.male.color
                ){_ in
                    
                    withAnimation{self.selectGender = .male}
                }
                RectButton(
                    icon: Gender.female.icon,
                    text: Gender.female.title,
                    isSelected: self.selectGender == Gender.female,
                    color: Gender.female.color
                ){_ in
                    withAnimation{self.selectGender = .female}
                }
            }
            VStack(spacing: Dimen.margin.regular){
                if self.needAgree {
                    HStack(spacing:0){
                        RadioButton(
                            type: .checkOn,
                            isChecked: self.isAgree,
                            text:String.button.privacyAgreement
                        ){ _ in
                            self.isAgree.toggle()
                        }
                        TextButton(
                            defaultText: String.button.terms,
                            isUnderLine: true
                        ){_ in
                            
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.privacy)
                            )
                        }
                    }
                }
                
                FillButton(
                    type: .fill,
                    text: String.button.save,
                    color: Color.app.white,
                    gradient: Color.app.orangeGradient
                ){_ in
                    self.onAction()
                }
                .modifier(Shadow())
                .opacity(self.selectGender?.rawValue == self.prevData?.rawValue
                         || self.selectGender == nil || !self.isAgree ? 0.3 : 1)
            }
            Spacer().modifier(MatchParent())
        }
        .onAppear{
            self.selectGender = self.prevData
            if self.needAgree {
                self.isAgree = false
            }
        }
    }
    
    private func onAction(){
        if !self.isAgree {return}
        if self.selectGender?.rawValue == self.prevData?.rawValue || self.selectGender == nil {return}
        self.edit(.init(gender: self.selectGender))
    }
}

#if DEBUG
struct SelectGenderEdit_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            SelectGenderEdit(
                type: .gender,
                edit: { data in }
            )
            .environmentObject(PagePresenter()).frame(width:320,height:600)
                
        }
    }
}
#endif

