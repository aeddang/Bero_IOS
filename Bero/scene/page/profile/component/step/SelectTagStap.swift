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

struct SelectTagStep: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    
    let profile:ModifyPetProfileData?
    let step:PageAddDog.Step
    let prev: (() -> Void)
    let next: ((ModifyPetProfileData) -> Void)
    
    @State var isShowing = false
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing:Dimen.margin.regular){
                HStack(alignment: .top, spacing: 0){
                    Spacer().modifier(MatchVertical(width: 0))
                    VStack(alignment: .leading, spacing: Dimen.margin.thin) {
                        ForEach(self.buttonSets) { data in
                            HStack(alignment: .center, spacing: Dimen.margin.thin) {
                                ForEach(data.cells) { cell in
                                    SortButton(
                                        type: self.selects.first(where: {cell.value == $0}) != nil
                                        ? .fill : .stroke,
                                        sizeType: .big,
                                        text: cell.title,
                                        color:
                                            self.selects.first(where: {cell.value == $0}) != nil
                                            ? Color.brand.primary : Color.app.grey400,
                                        isSort: false){
                                            self.selected(btn: cell, isSelect: !cell.isSelected)
                                        }
                                        .fixedSize()
                                
                                }
                            }
                        }
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
                        if self.selects.isEmpty {return}
                        self.next(
                            .init( hashStatus: PetProfile.exchangeListToString(self.selects))
                        )
                    }
                    .modifier(Shadow())
                    .opacity(self.selects.isEmpty ? 0.3 : 1)
                }
            }
            .opacity(self.isShowing ? 1 : 0)
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .getCode(let category,_):
                    self.setupCode(res, category: category)
                    self.setupData(geometry: geometry)
                default : break
                }
            }
            .onAppear{
                switch self.step {
                case .hash :
                    self.selects = PetProfile.exchangeStringToList(self.profile?.hashStatus)
                    self.dataProvider.requestData(q: .init(id: self.tag, type: .getCode(category: .personality)))
                default : break
                }
                
                withAnimation{  self.isShowing = true }
            }
        }
    }
    
    @State var buttons:[RadioBtnData] = []
    @State var buttonSets:[HashRows] = []
    @State var selects:[String] = []
    
    private func setupCode(_ res:ApiResultResponds,  category:MiscApi.Category){
        guard let datas = res.data as? [CodeData] else { return }
        switch self.step {
        case .hash :
            if category != .personality {return}
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
    
    
    struct HashRows:Identifiable{
        let id = UUID().uuidString
        let idx:Int
        var cells:[RadioBtnData]
    }
    private func setupData(geometry:GeometryProxy){
        var rows:[HashRows] = []
        var cells:[RadioBtnData] = []
        var lineWidth:CGFloat = 0
        let lineLimit = geometry.size.width - (Dimen.margin.regular*2)
        let margin = SortButton.SizeType.big.marginHorizontal * 2
        let font = SemiBoldTextStyle(size: SortButton.SizeType.big.textSize).textModifier
        self.buttons.forEach{ d in
            let btnWidth = font.getTextWidth(d.title) + margin
            let willSize = lineWidth + btnWidth
            //PageLog.d(d.title + " -> " + btnWidth.description, tag: self.tag )
            //PageLog.d("willSize -> " + willSize.description, tag: self.tag )
            if lineLimit >= willSize {
                cells.append(d)
                lineWidth += (btnWidth + Dimen.margin.thin)
            }else{
                rows.append(HashRows(idx:rows.count, cells: cells))
                cells = [d]
                lineWidth = (btnWidth + Dimen.margin.thin)
            }
        }
        if !cells.isEmpty {
            rows.append(HashRows(idx:rows.count, cells: cells))
        }
        self.buttonSets = rows
    }

    private func selected(btn:RadioBtnData, isSelect:Bool) {
        guard let value = btn.value else {return}
        btn.isSelected = isSelect
        if isSelect {
            self.selects.append(value)
        } else {
            if let find = self.selects.firstIndex(of: value) {
                self.selects.remove(at: find)
            }
        }
    }
        
}

#if DEBUG
struct SelectTagStep_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            SelectListStep(
                profile: .init(),
                step: .hash,
                prev: {},
                next: { data in }
            )
            .environmentObject(PagePresenter())
            .environmentObject(AppSceneObserver())
            .frame(width:320,height:600)
        }
    }
}
#endif

