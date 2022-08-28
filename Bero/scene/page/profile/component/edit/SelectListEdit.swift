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

struct SelectListEdit: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var prevData:String = ""
    let type:PageEditProfile.EditType
    let edit: ((PageEditProfile.EditData) -> Void)
    
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            if let caption = self.type.caption {
                Text(caption)
                    .modifier(SemiBoldTextStyle(size: Font.size.medium,color: Color.app.black))
                    .lineLimit(1)
                    .padding(.top, Dimen.margin.regularUltra)
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
                self.currentSelect == self.prevData
                ? 0.3
                : !self.isMultiSelectAble && self.finalSelect == nil ? 0.3 : 1)
            
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
            self.currentSelect = self.prevData
            switch self.type {
            case .immun :
                self.btnType = .stroke
                self.isMultiSelectAble = true
                self.showIndicators = false
                self.useSearch = false
                self.selects = PetProfile.exchangeStringToList(self.prevData)
                self.dataProvider.requestData(q: .init(id: self.tag, type: .getCode(category: .status)))
            default : break
            }
        }
    }
    @State var currentSelect:String = ""
    @State var buttons:[RadioBtnData] = []
    @State var selects:[String] = []
    @State var finalSelect: RadioBtnData?  = nil
    @State var isMultiSelectAble:Bool = false
    @State var showIndicators:Bool = false
    @State var useSearch:Bool = false
    @State var btnType:RadioButton.ButtonType = .blank
    private func setupCode(_ res:ApiResultResponds,  category:MiscApi.Category){
        guard let datas = res.data as? [CodeData] else { return }
        switch self.type {
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
            self.currentSelect = PetProfile.exchangeListToString(self.selects)
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
            self.currentSelect = btn.value ?? ""
        }
        
    }
    
    private func onAction(){
        switch self.type {
        case .immun :
            self.edit(.init( immunStatus: PetProfile.exchangeListToString(self.selects)))
        default : break
        }
    }
        
}

#if DEBUG
struct SelectListEdit_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            SelectListEdit(
                type: .immun,
                edit: { data in }
            )
            .environmentObject(PagePresenter())
            .environmentObject(KeyboardObserver())
            .environmentObject(AppSceneObserver())
            .frame(width:320,height:600)
        }
    }
}
#endif

