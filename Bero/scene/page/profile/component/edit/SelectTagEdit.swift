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

struct SelectTagEdit: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var prevData:String = ""
    let type:PageEditProfile.EditType
    let edit: ((PageEditProfile.EditData) -> Void)
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
                                            let isSelect = self.selects.first(where: {cell.value == $0}) != nil
                                            self.selected(btn: cell, isSelect: !isSelect)
                                            
                                        }
                                        .fixedSize()
                                }
                            }
                        }
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
                .opacity( self.currentSelect == self.prevData
                          ? 0.3
                          : self.selects.isEmpty ? 0.3 : 1)
                
            }
           
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
                self.currentSelect = self.prevData
                switch self.type {
                case .hash :
                    self.selects = PetProfile.exchangeStringToList(self.prevData)
                    self.dataProvider.requestData(q: .init(id: self.tag, type: .getCode(category: .personality)))
                default : break
                }
            }
        }
    }
    @State var currentSelect:String = ""
    @State var buttons:[RadioBtnData] = []
    @State var buttonSets:[HashRows] = []
    @State var selects:[String] = []
    
    private func setupCode(_ res:ApiResultResponds,  category:MiscApi.Category){
        guard let datas = res.data as? [CodeData] else { return }
        switch self.type {
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
        self.currentSelect = PetProfile.exchangeListToString(self.selects)
    }
    
    private func onAction(){
        switch self.type {
        case .hash :
            self.edit(.init( hashStatus: PetProfile.exchangeListToString(self.selects)))
        default : break
        }
    }
        
}

#if DEBUG
struct SelectTagEdit_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            SelectTagEdit(
                type: .hash,
                edit: { data in }
            )
            .environmentObject(PagePresenter())
            .environmentObject(AppSceneObserver())
            .frame(width:320,height:600)
        }
    }
}
#endif

