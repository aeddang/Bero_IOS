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
    var prevNeutralized:Bool? = nil
    let type:PageEditProfile.EditType
    var needAgree:Bool = false
    let edit: ((PageEditProfile.EditData,Bool?) -> Void)
    @State var selectGender:Gender? = nil
    @State var isNeutralized:Bool? = nil
    @State var isAgree:Bool = true
    var body: some View {
        VStack(spacing: Dimen.margin.heavy){
            VStack(spacing: Dimen.margin.regular){
                HStack(spacing:Dimen.margin.tinyExtra){
                    RectButton(
                        icon: Gender.male.icon,
                        text: Gender.male.title,
                        isSelected: self.selectGender == Gender.male,
                        color: Gender.male.color
                    ){_ in
                        
                        withAnimation{self.selectGender = .male}
                    }
                    if self.needAgree {
                        RectButton(
                            icon: Gender.neutral.icon,
                            text: Gender.neutral.title,
                            isSelected: self.selectGender == Gender.neutral,
                            color: Gender.neutral.color
                        ){_ in
                            withAnimation{self.selectGender = .neutral}
                        }
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
                if let isNeutralized = self.isNeutralized {
                    AgreeButton(
                        type: .neutralized,
                        isChecked: isNeutralized
                    ){ check in
                        self.isNeutralized = check
                    }
                }
            }
            VStack(spacing: Dimen.margin.regular){
                if self.needAgree {
                    AgreeButton(
                        type: .privacy,
                        isChecked: self.isAgree
                    ){ _ in
                        self.isAgree.toggle()
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
                .opacity(
                    self.isNeutralized != self.prevNeutralized
                    ? 1
                    : self.selectGender?.rawValue == self.prevData?.rawValue
                         || self.selectGender == nil || !self.isAgree ? 0.3 : 1)
            }
            Spacer().modifier(MatchParent())
        }
        .onAppear{
            self.selectGender = self.prevData
            self.isNeutralized = self.prevNeutralized
            if self.needAgree {
                self.isAgree = self.prevData != nil
            }
        }
    }
    
    private func onAction(){
        if !self.isAgree {return}
        if self.isNeutralized != self.prevNeutralized {
            self.edit(.init(gender: self.selectGender), self.isNeutralized)
            return
        }
        if self.selectGender?.rawValue == self.prevData?.rawValue || self.selectGender == nil {return}
        self.edit(.init(gender: self.selectGender), self.isNeutralized)
    }
}

#if DEBUG
struct SelectGenderEdit_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            SelectGenderEdit(
                type: .gender,
                edit: { data,  isNeutralized in }
            )
            .environmentObject(PagePresenter()).frame(width:320,height:600)
                
        }
    }
}
#endif

