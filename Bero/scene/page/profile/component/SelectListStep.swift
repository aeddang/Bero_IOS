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

struct SelectListStep: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    let profile:ModifyPetProfileData?
    let step:PageAddDog.Step
    let prev: (() -> Void)
    let next: ((ModifyPetProfileData) -> Void)
    
    @State var isShowing = false
    @State var isSearch:Bool = false
    var body: some View {
        VStack(spacing:0){
            if self.useSearch {
                InputSearch(
                    title: nil,
                    input: self.$keyword,
                    placeHolder: self.step.placeHolder,
                    isFocus: self.isSearch,
                    onFocus: {
                        withAnimation{ self.isSearch = true }
                    },
                    onChange: { _ in
                        self.searching()
                    },
                    onAction: {
                        if self.keyword.isEmpty {
                            self.appSceneObserver.event = .toast("input search keyword")
                            return
                        }
                        AppUtil.hideKeyboard()
                        self.search()
                    }
                )
            }
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                axes: .vertical,
                marginVertical: Dimen.margin.medium,
                marginHorizontal: self.isMultiSelectAble ? 0 : Dimen.margin.tinyExtra,
                spacing:self.btnType.spacing,
                isRecycle: true,
                useTracking: false
            ){
                ForEach(self.buttons) { btn in
                    RadioButton(
                        type: self.btnType,
                        isChecked:
                            !self.isMultiSelectAble
                                ? self.finalSelect?.title == btn.title
                                : self.selects.first(where: {btn.title == $0}) != nil,
                        text: btn.title
                    ){isSelect in
                        AppUtil.hideKeyboard()
                        self.selected(btn: btn, isSelect: isSelect)
                    }
                    .id(btn.index)
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
                    color:Color.app.white,
                    gradient: Color.app.orangeGradient
                ){_ in
                   
                    switch self.step {
                    case .breed :
                        if self.finalSelect == nil {return}
                        self.next(
                            .init( breed: self.finalSelect?.title)
                        )
                    case .immun :
                        self.next(
                            .init( immunStatus: PetProfile.exchangeListToString(self.selects))
                        )
                    default : break
                    }
                }
                .modifier(Shadow())
                .opacity(!self.isMultiSelectAble && self.finalSelect == nil ? 0.3 : 1)
            }
        }
        .opacity(self.isShowing ? 1 : 0)
        .onReceive(self.keyboardObserver.$isOn){ on in
            if self.pageObservable.layer != .top { return }
            self.updatekeyboardStatus(on:on)
        }
        .onAppear{
            switch self.step {
            case .breed :
                self.btnType = .blank
                self.isMultiSelectAble = false
                self.useSearch = true
                if let breed = self.profile?.breed {
                    self.finalSelect = RadioBtnData(title: breed, index: 0)
                }
                var find:Int?  = nil
                let range = 0 ..< 100
                self.buttons = range.map{ num in
                    let title = "dog" + num.description
                    if title == self.finalSelect?.title {
                        find = num
                    }
                    return RadioBtnData(
                        title: title,
                        index: num
                    )
                }
                if let find = find {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                        self.infinityScrollModel.uiEvent = .scrollMove(find)
                    }
                }
                
            case .immun :
                self.btnType = .stroke
                self.isMultiSelectAble = true
                self.useSearch = false
                self.buttons = [
                    RadioBtnData(
                        title: "Neutralized",
                        index: 0),
                    RadioBtnData(
                        title: "Distemper Vaccinated",
                        index: 1),
                    RadioBtnData(
                        title: "Hepatitis Vaccinated",
                        index: 2),
                    RadioBtnData(
                        title: "Parovirus Vaccinated",
                        index: 3),
                    RadioBtnData(
                        title: "Rabies Vaccinated",
                        index: 4)
                ]
                self.selects = PetProfile.exchangeStringToList(self.profile?.immunStatus)
            default : break
            }
            withAnimation{  self.isShowing = true }
        }
    }
    
    @State var keyword:String = ""
    @State var buttons:[RadioBtnData] = []
    @State var selects:[String] = []
    @State var finalSelect: RadioBtnData?  = nil
    @State var isMultiSelectAble:Bool = false
    @State var useSearch:Bool = false
    @State var btnType:RadioButton.ButtonType = .blank
    private func selected(btn:RadioBtnData, isSelect:Bool) {
        if self.isMultiSelectAble {
            btn.isSelected = isSelect
            if isSelect {
                self.selects.append(btn.title)
            } else {
                if let find = self.selects.firstIndex(of: btn.title) {
                    self.selects.remove(at: find)
                }
            }
        }else {
            if isSelect {
                if let find = self.finalSelect {
                    find.isSelected = false
                }
                btn.isSelected = true
            } else {
                btn.isSelected = false
            }
            self.finalSelect = btn
        }
    }
    
    @State var isSearching = false
    private func searching(){
        if self.isSearching {return}
        self.isSearching = true
        let randomInit = Int.random(in: 0..<6)
        let randomEnd = Int.random(in: 10..<16)
        let range = randomInit ..< randomEnd
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.buttons = range.map{ num in
                let title = "dog" + num.description
                return RadioBtnData(
                    title: title,
                    index: num
                )
            }
            self.isSearching = false
        }
    }
    
    private func search(){
        
    }
    private func updatekeyboardStatus(on:Bool) {
        if !on {
            self.isSearch = false
        }
    }
        
        
}

#if DEBUG
struct SearchStap_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            SelectListStep(
                profile: .init(),
                step: .immun,
                prev: {},
                next: { data in }
            )
            .environmentObject(PagePresenter())
            .environmentObject(KeyboardObserver())
            .environmentObject(AppSceneObserver())
            .frame(width:320,height:600)
        }
    }
}
#endif

