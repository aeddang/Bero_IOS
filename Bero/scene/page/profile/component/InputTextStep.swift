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




struct InputTextStep: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    let profile:ModifyPetProfileData?
    let step:PageAddDog.Step
    let prev: (() -> Void)
    let next: ((ModifyPetProfileData) -> Void)
   
    @State var tip:String? = nil
    @State var input:String = ""
    @State var isEditing:Bool = false
    var body: some View {
        VStack(spacing: Dimen.margin.tiny){
            InputText(
                input: self.$input,
                placeHolder: self.step.placeHolder,
                tip: self.tip,
                isFocus: self.isEditing,
                keyboardType: .namePhonePad,
                onFocus: {
                    withAnimation{ self.isEditing = true }
                },
                onChange: { text in
                    
                },
                onAction: {
                    self.onAction()
                }
            )
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
                    .modifier(Shadow())
                }
                FillButton(
                    type: .fill,
                    text: String.button.next,
                    color: Color.app.white,
                    gradient: Color.app.orangeGradient
                ){_ in
                    self.onAction()
                }
                .modifier(Shadow())
                .opacity(self.input.isEmpty ? 0.3 : 1)
            }
        }
        .onReceive(self.keyboardObserver.$isOn){ on in
            if self.pageObservable.layer != .top { return }
            self.updatekeyboardStatus(on:on)
        }
        .onAppear{
            self.input = self.profile?.name ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                withAnimation{  self.isEditing = true }
            }
        }
    }
    
    private func onAction(){
        if self.input.isEmpty {return}
        self.next(
            .init(
                name : self.input
            )
        )
    }
    
    private func updatekeyboardStatus(on:Bool) {
        if !on {
            withAnimation{  self.isEditing = false }
        }
    }
}

#if DEBUG
struct InputTextStep_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            InputTextStep(
                profile: .init(),
                step: .name,
                prev: {},
                next: { data in }
            )
            .environmentObject(PagePresenter()).frame(width:320,height:100)
                
        }
    }
}
#endif

