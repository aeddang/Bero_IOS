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

struct SelectGenderStep: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    let profile:ModifyPetProfileData?
   
    let step:PageAddDog.Step
    let prev: (() -> Void)
    let next: ((ModifyPetProfileData) -> Void)
    @State var selectGender:Gender? = nil
    @State var isNeutralized:Bool = false
    @State var isShowing = false
    var body: some View {
        VStack(spacing: Dimen.margin.tiny){
            
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
            AgreeButton(
                type: .neutralized,
                isChecked: self.isNeutralized
            ){ check in
                self.isNeutralized = check
            }
            Spacer()
            HStack (spacing:Dimen.margin.tinyExtra){
                if !self.step.isFirst {
                    FillButton(
                        type: .fill,
                        text: String.button.goBack,
                        color: Color.app.grey50,
                        textColor: Color.app.grey400
                    ){_ in
                        self.prev()
                    }
                }
                FillButton(
                    type: .fill,
                    text: String.button.next,
                    color:Color.app.white,
                    gradient: Color.app.orangeGradient
                ){_ in
                    if self.selectGender == nil {return}
                    self.next(
                        .init(
                            gender:self.selectGender,
                            isNeutralized: self.isNeutralized
                        )
                    )
                }
                .modifier(Shadow())
                .opacity(self.selectGender == nil ? 0.3 : 1)
            }
        }
        .opacity(self.isShowing ? 1 : 0)
        .onAppear{
            self.selectGender = self.profile?.gender
            self.isNeutralized = self.profile?.isNeutralized ?? false
            withAnimation{  self.isShowing = true }
        }
    }
}

#if DEBUG
struct SelectGenderStep_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            SelectGenderStep(
                profile: .init(),
                step: .gender,
                prev: {},
                next: { data in }
            )
            .environmentObject(PagePresenter()).frame(width:320,height:600)
                
        }
    }
}
#endif

