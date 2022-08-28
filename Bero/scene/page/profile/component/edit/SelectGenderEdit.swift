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
    let edit: ((PageEditProfile.EditData) -> Void)
    @State var selectGender:Gender? = nil
   
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
            FillButton(
                type: .fill,
                text: String.button.save,
                color: Color.app.white,
                gradient: Color.app.orangeGradient
            ){_ in
                self.onAction()
            }
            .modifier(Shadow())
            .opacity(self.selectGender?.rawValue == self.prevData?.rawValue || self.selectGender == nil ? 0.3 : 1)
            Spacer().modifier(MatchParent())
        }
        .onAppear{
            self.selectGender = self.prevData
        }
    }
    
    private func onAction(){
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

