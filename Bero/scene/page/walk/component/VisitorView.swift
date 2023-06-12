//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import GoogleMaps

struct VisitorView: PageComponent, Identifiable{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    let id:String = UUID().uuidString
    let placeId:Int
    var totalCount:Int = 0
    
    var body: some View {
        ZStack(alignment: .top){
            DragDownArrow(
                infinityScrollModel: self.infinityScrollModel,
                text: String.button.close)
            .padding(.top, Dimen.margin.regular)
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                axes: .vertical,
                showIndicators : false,
                marginVertical: Dimen.margin.heavy,
                marginHorizontal: Dimen.app.pageHorinzontal,
                spacing:Dimen.margin.regularExtra,
                isRecycle: true,
                useTracking: true
            ){
                Text(String.pageText.walkVisitorTitle.replace(self.totalCount.description))
                    .modifier(SemiBoldTextStyle(
                        size: Font.size.regular,
                        color: Color.app.black
                    ))
                ForEach(self.datas) { data in
                    PetProfileUser(profile: data,
                                   friendStatus: data.isMypet
                                   ? nil
                                   : data.isFriend ? .chat : .norelation){
                        if self.dataProvider.user.isSameUser(userId: data.userId) {
                            self.appSceneObserver.event = .toast(String.alert.itsMe)
                            /*
                            self.pagePresenter.changePage(
                                PageProvider.getPageObject(.my)
                            )*/
                        } else {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.user).addParam(key: .id, value:data.userId)
                            )
                        }
                        
                    }
                    .onAppear{
                        if  data.index == (self.datas.count-1) {
                            self.infinityScrollModel.event = .bottom
                        }
                    }
                }
            }
        }
        .background(Color.app.white)
        .onReceive(self.infinityScrollModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .bottom : self.loadVisitor()
            default : break
            }
        }
        .onReceive(self.infinityScrollModel.$uiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .reload :
                self.resetScroll()
                self.loadVisitor()
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            
            switch res.type {
            case .getPlaceVisitors(let placeId, let page, _):
                if self.placeId != placeId {return}
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
            case .getPlaceVisitors(let placeId, _, _):
                if self.placeId != placeId {return}
                self.pageObservable.isInit = true
                
            default : break
            }
        }
        .onAppear(){
            self.loadVisitor()
        }
    }
    
    @State var datas:[PetProfile] = []
    @State var isEmpty:Bool = false
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.datas = []
        self.infinityScrollModel.reload()
    }
    
    private func loadVisitor(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
    
        self.dataProvider.requestData(q:
                .init(id: self.tag, type:.getPlaceVisitors(placeId: self.placeId, page: self.infinityScrollModel.page)))
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [UserAndPet] else { return }
        self.loadedVisitor(datas: datas)
    }
    
    private func loadedVisitor(datas:[UserAndPet]){
        var added:[PetProfile] = []
        let start = self.datas.count
        let end = start + datas.count
        let me = self.dataProvider.user.userId
        added = zip(start...end, datas).map{ idx, d in
            let profile = PetProfile(data: d.pet ?? PetData(), userId: d.user?.userId,
                                     isMyPet: d.user?.userId == me,
                                     isFriend: d.user?.isFriend ?? false,
                                     index: start + idx
            )
            profile.level = d.user?.level
            return profile
            //return MultiProfileListItemData().setData(d,  idx: idx)
        }
        self.datas.append(contentsOf: added)
        if self.datas.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }
}

struct VisitorHorizontalView: PageComponent, Identifiable{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    let place:Place
    var datas:[MultiProfileListItemData] = []
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageText.walkVisitorTitle.replace(self.place.visitorCount.description),
                     buttons:self.place.placeId != -1 ? [.viewMore] : []){ type in
                switch type {
                case .viewMore :
                    self.pagePresenter.openPopup(PageProvider.getPageObject(.popupPlaceVisitor).addParam(key: .data, value: self.place))
                default : break
                }
            }
            .padding(.horizontal, Dimen.app.pageHorinzontal)
           
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                axes: .horizontal,
                showIndicators : false,
                marginVertical: 0,
                marginHorizontal: Dimen.app.pageHorinzontal,
                spacing:Dimen.margin.thin,
                isRecycle: false,
                useTracking: false
            ){
                ForEach(self.datas) { data in
                    Button(action: {
                        self.moveUser(id: data.contentID)
                    }) {
                        MultiProfile(
                            id: "",
                            type: .pet,
                            imagePath: data.pet?.imagePath,
                            imageSize: Dimen.profile.mediumUltra,
                            name: data.pet?.name ?? data.user?.nickName,
                            lv:data.lv,
                            buttonAction: {
                                self.moveUser(id: data.contentID)
                            }
                        )
                    }
                }
            }
            .frame(height: 106)
        }
        .background(Color.app.white)
    }
    
    private func moveUser(id:String? = nil){
        if self.dataProvider.user.isSameUser(userId: id) {
            self.appSceneObserver.event = .toast(String.alert.itsMe)
            
        } else {
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.user).addParam(key: .id, value:id)
            )
        }
    }
}

#if DEBUG
struct VisitorView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            VisitorView(
                placeId: 0,
                totalCount: 100
            )
        }
        .padding(.all, 10)
        .background(Color.app.white)
        .environmentObject(PagePresenter())
        .environmentObject(PageSceneObserver())
        .environmentObject(Repository())
        .environmentObject(DataProvider())
        .environmentObject(AppSceneObserver())
    }
}
#endif
