//
//  AlarmList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import Foundation
import SwiftUI

struct AlarmList: PageComponent{
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var marginBottom:CGFloat = Dimen.margin.medium
    @Binding var isEdit:Bool
    @State var isCheckAll:Bool = false
   
    var body: some View {
        VStack(spacing:0){
            if self.isEmpty {
                EmptyItem(type: .myList)
                    .padding(.top, Dimen.margin.regularUltra)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                Spacer().modifier(MatchParent())
            } else {
                InfinityScrollView(
                    viewModel: self.infinityScrollModel,
                    axes: .vertical,
                    showIndicators : false,
                    marginTop: Dimen.margin.regularUltra,
                    marginBottom: self.marginBottom,
                    marginHorizontal: Dimen.app.pageHorinzontal,
                    spacing:Dimen.margin.regularUltra,
                    isRecycle: true,
                    useTracking: true
                ){
                    ForEach(self.alarms) { data in
                        AlarmListItem(data: data, isEdit: self.$isEdit)
                        .id(data.hashId)
                        .onAppear{
                            if data.index == (self.alarms.count-1) {
                                self.infinityScrollModel.event = .bottom
                            }
                        }
                    }
                }
            }
            if self.isEdit {
                HStack(spacing:Dimen.margin.micro){
                    FillButton(
                        type: .fill,
                        text: String.button.checkAll,
                        color: Color.app.black,
                        isActive: self.isCheckAll
                    ){_ in
                        withAnimation{
                            self.isCheckAll.toggle()
                        }
                        self.alarms.forEach{$0.isDelete = self.isCheckAll}
                    }
                    FillButton(
                        type: .fill,
                        text: String.button.delete,
                        color: Color.brand.primary,
                        isActive: true
                    ){_ in
                        self.deleteAlarm()
                    }
                }
                .padding(.vertical, Dimen.margin.thin)
                .padding(.horizontal, Dimen.app.pageHorinzontal)
            }
        }
        .onReceive(self.infinityScrollModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .bottom : self.loadAlarm()
            default : break
            }
        }
        .onReceive(self.infinityScrollModel.$uiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .reload : self.updateAlarm()
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            switch res.type {
            case .getAlarm(let page ,_):
                if page == 0 {
                    self.resetScroll()
                }
                self.loaded(res)
                self.pageObservable.isInit = true
                
            default : break
            }
            
        }
        .onReceive(self.dataProvider.$error){err in
            guard let err = err else { return }
            
            switch err.type {
            case .getAlarm :
                self.pageObservable.isInit = true
                
            default : break
            }
            
        }
        .onReceive (self.appObserver.$page) { iwg in
            guard let pageId = iwg?.page?.pageID else { return }
            switch pageId {
            case .alarm :
                self.updateAlarm()
                
            default: break
            }
            //self.appObserverMove(iwg)
        }
        .onAppear(){
            self.updateAlarm()
            self.pageObservable.isInit = true
        }
    }
    @State var isEmpty:Bool = false
    @State var alarms:[AlarmListItemData] = []
    private func updateAlarm(){
        self.resetScroll()
        self.loadAlarm()
    }
    
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.isCheckAll = false
        self.alarms = []
        self.infinityScrollModel.reload()
    }
    
    private func loadAlarm(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
    
        self.dataProvider.requestData(q: .init(id: self.tag, type:
            .getAlarm(page: self.infinityScrollModel.page)))
         
        
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [AlarmData] else { return }
        self.loadedAlarm(datas: datas)
    }
    
    private func loadedAlarm(datas:[AlarmData]){
        var added:[AlarmListItemData] = []
        let start = self.alarms.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return AlarmListItemData().setData(d, idx: idx)
        }
        self.alarms.append(contentsOf: added)
        if self.alarms.isEmpty {
            withAnimation{
                self.isEmpty = true
                self.isEdit = false
            }
        } else {
            withAnimation{
                self.isEmpty = false
            }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
        
    }
    
    private func deleteAlarm(){
        let selects = self.alarms.filter{$0.isDelete}
        if selects.isEmpty {
            self.appSceneObserver.event = .toast(String.alert.noItemsSelected)
            return
        }
        /*
        let del = selects.reduce("", {$0 + "," + $1.pictureId.description}).dropFirst()
        self.dataProvider.requestData(q: .init(id: self.currentId, type:
                .deleteAlarmPictures(ids: String(del))
        ))
         */
    }
}


