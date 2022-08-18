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
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    let profile:ModifyPetProfileData?
    let step:PageAddDog.Step
    let prev: (() -> Void)
    let next: ((ModifyPetProfileData) -> Void)
   
    @State var tip:String? = nil
    @State var input:String = ""
    @State var inputTypeIndex:Int = 0
    @State var isEditing:Bool = false
    @State var isShowing = false
    var body: some View {
        VStack(spacing: Dimen.margin.medium){
            if let types = self.step.inputType {
                MenuTab(
                    viewModel:self.navigationModel,
                    buttons: types,
                    selectedIdx: self.inputTypeIndex
                )
            }
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
            if !self.isEditing, let info = self.step.inputDescription {
                Text(info)
                    .modifier(RegularTextStyle(
                        size: Font.size.thin,
                        color: Color.app.grey400
                    ))
                .padding(.top, Dimen.margin.regular)
            }
            Spacer().modifier(MatchParent())
            if self.step.isSkipAble && !self.isEditing{
                TextButton(
                    defaultText: String.button.skipNow,
                    textModifier:TextModifier(
                        family:Font.family.medium,
                        size:Font.size.thin,
                        color: Color.app.grey500),
                    isUnderLine: true)
                {_ in
                    self.next(.init())
                }
            }
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
                    color: Color.app.white,
                    gradient: Color.app.orangeGradient
                ){_ in
                    self.onAction()
                }
                .modifier(Shadow())
                .opacity(self.input.isEmpty ? 0.3 : 1)
            }
        }
        .opacity(self.isShowing ? 1 : 0)
        .onReceive(self.keyboardObserver.$isOn){ on in
            if self.pageObservable.layer != .top { return }
            self.updatekeyboardStatus(on:on)
        }
        .onReceive(self.navigationModel.$index){ index in
            if self.inputTypeIndex == index {return}
            self.onPrevDataBinding()
        }
        .onAppear{
            switch self.step {
            case .identify :
                if self.profile?.animalId?.isEmpty == false {
                    self.navigationModel.index = 0
                }else if self.profile?.microfin?.isEmpty == false {
                    self.navigationModel.index = 1
                }
            default : break
            }
            self.onPrevDataBinding()
            withAnimation{  self.isShowing = true }
            if self.step.isSkipAble {return}
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                 self.isEditing = true 
            }
        }
    }
    
    private func onPrevDataBinding(){
        switch self.step {
        case .name :
            self.input = self.profile?.name ?? ""
        case .identify :
            if self.navigationModel.index == 0 {
                self.input = self.profile?.animalId ?? ""
                self.inputTypeIndex = 0
                
            } else {
                self.input = self.profile?.microfin ?? ""
                self.inputTypeIndex = 1
                
            }
        default : break
        }
    }
    
    private func onAction(){
        if self.input.isEmpty {return}
        switch self.step {
        case .name :
            self.next(.init(name : self.input))
        case .identify :
            if self.inputTypeIndex == 0 {
                self.next(.init(animalId : self.input))
                
            }else {
                self.next(.init(microfin : self.input))
            }
        default : break
        }
        
    }
    
    private func updatekeyboardStatus(on:Bool) {
        if !on {
            self.isEditing = false
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
            .environmentObject(PagePresenter())
            .environmentObject(KeyboardObserver())
            .frame(width:320,height:400)
        }
    }
}
#endif

