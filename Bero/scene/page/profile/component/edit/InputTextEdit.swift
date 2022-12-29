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

struct InputTextEdit: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    var prevData:String = ""
    let type:PageEditProfile.EditType
    var needAgree:Bool = false
    let edit: ((PageEditProfile.EditData) -> Void)
    @State var tip:String? = nil
    @State var input:String = ""
    @State var inputTypeIndex:Int = 0
    @State var isEditing:Bool = false
    @State var isAgree:Bool = true
    @State var limitedLine:Int = 1
    @State var limitedTextLength:Int = 100
    var body: some View {
        VStack(spacing: Dimen.margin.heavy){
            
            InputText(
                title: self.type.caption,
                input: self.$input,
                placeHolder: self.type.placeHolder,
                tip: self.tip,
                isFocus: self.isEditing,
                limitedLine: self.limitedLine,
                limitedTextLength: self.limitedTextLength,
                keyboardType: self.type.keyboardType,
                returnKeyType: self.type.keyboardReturnType,
                onFocus: {
                    withAnimation{ self.isEditing = true }
                },
                onChange: { text in
                    
                },
                onAction: {
                    self.onAction()
                }
            )
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
                .opacity(self.input.isEmpty || self.input == self.prevData || !self.isAgree ? 0.3 : 1)
            }
            Spacer().modifier(MatchParent())
        }
        .onReceive(self.keyboardObserver.$isOn){ on in
            if self.pageObservable.layer != .top { return }
            self.updatekeyboardStatus(on:on)
        }
        
        .onAppear{
            switch self.type {
            case .introduction :
                self.limitedLine = 5
                self.limitedTextLength = 100
            case .weight, .height :
                self.limitedTextLength = 10
                self.limitedLine = 1
            case .animalId :
                self.limitedTextLength = 15
                self.limitedLine = 1
            case .microchip :
                self.limitedTextLength = 9
                self.limitedLine = 1
            default :
                self.limitedTextLength = 20
                self.limitedLine = 1
            }
            self.input = self.prevData
            if self.needAgree {
                self.isAgree = !self.prevData.isEmpty
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                 self.isEditing = true
            }
        }
    }
    
    private func onAction(){
        if self.input.isEmpty {return}
        if !self.isAgree {return}
        if self.input == self.prevData {return}
        switch self.type {
        case .name :
            self.edit(.init(name : self.input))
        case .introduction :
            self.edit(.init(introduction : self.input))
        case .weight :
            self.edit(.init(weight : self.input.toDouble()))
        case .height :
            self.edit(.init(size : self.input.toDouble()))
        case .microchip :
            self.edit(.init(microchip : self.input))
        case .animalId :
            self.edit(.init(animalId : self.input))
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
struct InputTextEdit_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            InputTextEdit(
                type: .name,
                edit: { data in }
            )
            .environmentObject(PagePresenter())
            .environmentObject(KeyboardObserver())
            .frame(width:320,height:400)
        }
    }
}
#endif

