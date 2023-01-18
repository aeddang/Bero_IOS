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
    @EnvironmentObject var dataProvider:DataProvider
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
                showIndicators: self.showIndicators,
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
                                ? self.finalSelect?.value == btn.value
                                : self.selects.first(where: {btn.value == $0}) != nil,
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
                            .init( breed: self.finalSelect?.value)
                        )
                    /*
                    case .immun :
                        self.next(
                            .init( immunStatus: PetProfile.exchangeListToString(self.selects))
                        )
                    */
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
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getCode(let category,_):
                self.setupCode(res, category: category)
            default : break
            }
        }
        .onAppear{
            switch self.step {
            case .breed :
                self.btnType = .blank
                self.isMultiSelectAble = false
                self.showIndicators = true
                self.useSearch = true
                if let breed = self.profile?.breed {
                    self.finalSelect = RadioBtnData(title: breed, value:breed, index: 0)
                }
                self.dataProvider.requestData(q: .init(id: self.tag, type: .getCode(category: .breed, searchKeyword: self.keyword)))
            /*
            case .immun :
                self.btnType = .stroke
                self.isMultiSelectAble = true
                self.showIndicators = false
                self.useSearch = false
                self.selects = PetProfile.exchangeStringToList(self.profile?.immunStatus)
                self.dataProvider.requestData(q: .init(id: self.tag, type: .getCode(category: .status)))
             */
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
    @State var showIndicators:Bool = false
    @State var useSearch:Bool = false
    @State var btnType:RadioButton.ButtonType = .blank
    private func setupCode(_ res:ApiResultResponds,  category:MiscApi.Category){
        guard let datas = res.data as? [CodeData] else { return }
        switch self.step {
        case .breed :
            if category != .breed {return}
            self.isSearching = false
            var index:Int = 0
            var find:Int? = nil
            self.buttons = datas.map{ data in
                let num = index
                if data.id?.description == self.finalSelect?.value {
                    find = num
                }
                index += 1
                return RadioBtnData(
                    title: data.value ?? "",
                    value: data.id?.description,
                    index: num
                )
            }
            if let find = find {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                    self.infinityScrollModel.uiEvent = .scrollMove(find)
                }
            }
        /*
        case .immun :
            if category != .status {return}
            var index:Int = 0
            self.buttons = datas.map{ data in
                let num = index
                index += 1
                return RadioBtnData(
                    title: data.value ?? "",
                    value: data.id?.description,
                    index: num
                )
            }
         */
        default : break
        }
        
    }
    
    
    private func selected(btn:RadioBtnData, isSelect:Bool) {
        guard let value = btn.value else {return}
        if self.isMultiSelectAble {
            btn.isSelected = isSelect
            if isSelect {
                self.selects.append(value)
            } else {
                if let find = self.selects.firstIndex(of: value) {
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
        self.dataProvider.requestData(q: .init(id: self.tag, type: .getCode(category: .breed, searchKeyword: self.keyword)))
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
                step: .breed,
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

