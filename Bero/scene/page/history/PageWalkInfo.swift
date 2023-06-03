//
//  PageTest.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import Combine
import Firebase
import FacebookLogin
import FirebaseCore
import GoogleSignInSwift

extension PageWalkInfo {
    static let topScrollDefault:CGFloat = 240
    static let topScrollMax:CGFloat = 100
}

struct PageWalkInfo: PageView {
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(alignment: .leading, spacing: 0 ){
                    ZStack{
                        TitleTab(
                            //infinityScrollModel: self.infinityScrollModel,
                            title: String.pageTitle.walkSummary ,
                            useBack: true, action: { type in
                                switch type {
                                case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                                default : break
                                }
                            })
                    }
                    .modifier(PageTop())
                    .zIndex(999)
                    .background(Color.app.white)
                    .offset(y:min(0, -Dimen.app.top * (self.imageScale-1)))
                    ZStack(alignment: .top){
                        ZStack(alignment: .topTrailing){
                            if let path = self.mission?.pictureUrl {
                                ImageView(url: path,
                                          contentMode: .fill,
                                          noImg: Asset.noImg1_1 )
                                .frame(
                                    width: geometry.size.width * max(1.0,self.imageScale),
                                    height: geometry.size.width * max(1.0,self.imageScale)
                                )
                                .opacity(self.useScrollUi ? max(self.imageScale, 0.5) : 1)
                                .frame(
                                    width: geometry.size.width ,
                                    height: geometry.size.width
                                )
                                .onTapGesture{
                                    self.movePicture()
                                }
                            } else {
                                Image(Asset.noImg1_1)
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .modifier(MatchParent())
                            }
                            if self.isMe, let pets = self.mission?.user?.pets {
                                HStack(spacing:Dimen.margin.micro){
                                    ForEach(pets) { profile in
                                        
                                        Button(action: {
                                            self.pagePresenter.openPopup(
                                                PageProvider.getPageObject(.dog)
                                                    .addParam(key: .id, value: profile.petId)
                                                    .addParam(key: .subData, value: self.dataProvider.user)
                                            )
                                        }) {
                                            ProfileImage(
                                                image:profile.image,
                                                imagePath: profile.imagePath,
                                                isSelected: true,
                                                strokeColor: Color.app.white,
                                                size: Dimen.profile.thin,
                                                emptyImagePath: Asset.image.profile_dog_default
                                            )
                                        }
                                    }
                                }
                                .fixedSize()
                                .padding(.all, Dimen.margin.regular)
                                .padding(.top, min(0,Dimen.app.top * (1-self.imageScale)))
                                .opacity(2.0 - self.imageScale)
                            } else if !self.isMe ,
                                      let userId = self.user?.userId ?? self.userProfile?.userId {
                                let img = self.user?.representativeImage ?? self.userProfile?.imagePath ?? ""
                                Button(action: {
                                    self.pagePresenter.openPopup(
                                        PageProvider.getPageObject(.user)
                                            .addParam(key: .id, value:userId)
                                            .addParam(key:.data, value: self.user)
                                    )
                                    
                                }) {
                                    ProfileImage(
                                        imagePath: img,
                                        isSelected: true,
                                        strokeColor: Color.app.white,
                                        size: Dimen.profile.thin,
                                        emptyImagePath: Asset.image.profile_user_default
                                    )
                                }
                                .padding(.all, Dimen.margin.regular)
                                .padding(.top, min(0,Dimen.app.top * (1-self.imageScale)))
                                .opacity(2.0 - self.imageScale)
                            }
                                    
                        }
                        .modifier(MatchHorizontal(height: geometry.size.width))
                        //.clipped()
                        
                        VStack(spacing:0){
                            Spacer().frame(
                                width: 0,
                                height: max(0,Self.topScrollDefault + self.topOffSet)
                            )
                            ZStack{
                                if let mission = self.mission {
                                    InfinityScrollView(
                                        viewModel: self.infinityScrollModel,
                                        axes: .vertical,
                                        showIndicators : false,
                                        marginTop: Dimen.margin.regular,
                                        marginBottom: Dimen.margin.medium,
                                        marginHorizontal: 0,
                                        spacing:0,
                                        isRecycle: true,
                                        useTracking: true
                                    ){
                                        HStack(spacing: 0){
                                            VStack(alignment: .leading, spacing: 0){
                                                Spacer().modifier(MatchHorizontal(height: 0))
                                                WalkTopInfo(mission: mission, isMe: self.isMe)
                                            }
                                            if !self.isMe, let pets = self.mission?.user?.pets {
                                                HStack(spacing:Dimen.margin.microExtra){
                                                    ForEach(pets) { profile in
                                                        ProfileImage(
                                                            image:profile.image,
                                                            imagePath: profile.imagePath,
                                                            size: Dimen.profile.tiny,
                                                            emptyImagePath: Asset.image.profile_dog_default
                                                        )
                                                    }
                                                }
                                                .fixedSize()
                                            }
                                        }
                                        .padding(.horizontal, Dimen.app.pageHorinzontal)
                                        
                                        WalkPropertySection(mission: mission)
                                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                                            .padding(.top, Dimen.margin.regular)
                                        
                                        WalkPlayInfo(mission: mission)
                                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                                            .padding(.top, Dimen.margin.regular)
                                            .padding(.bottom, Dimen.margin.medium)
                                        
                                        ForEach(self.pictureSets) { dataSet in
                                            HStack(spacing: Dimen.margin.regularExtra){
                                                ForEach(dataSet.datas) { data in
                                                    ListItem(
                                                        imagePath: data.pictureUrl,
                                                        imgSize: self.pictureSize,
                                                        move: {
                                                            self.movePictureViewer(path: data.pictureUrl )
                                                        }
                                                    )
                                                }
                                                if !dataSet.isFull {
                                                    Spacer().frame(
                                                        width: self.pictureSize.width,
                                                        height: self.pictureSize.height)
                                                }
                                            }
                                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                                        }
                                    }
                                    
                                } else {
                                    Spacer().modifier(MatchParent())
                                }
                            }
                            .modifier(BottomFunctionTab(margin:0))
                        }
                    }
                }
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.infinityScrollModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCancel : break
                    //withAnimation{ self.imageScale = 1 }
                default : break
                }
            }
            .onReceive(self.infinityScrollModel.$scrollPosition){ scrollPos  in
                self.imageScale = 1.0 + (scrollPos*0.01)
                if !self.useScrollUi { return }
                if scrollPos > 0 {return}
                PageLog.d("scrollPos " + scrollPos.description, tag: self.tag)
                self.topOffSet = max(scrollPos, -Self.topScrollMax)
            }
            .onReceive(self.dataProvider.$result){res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .getWalk(let walkId) :
                    if walkId != self.walkId {return}
                    self.loaded(res)
                    self.pageObservable.isInit = true
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let mission = obj.getParamValue(key: .data) as? Mission{
                    self.mission = mission
                    self.user = mission.user
                    self.updatedData()
                    self.pageObservable.isInit = true
                    return
                } else if let user = obj.getParamValue(key: .data) as? User{
                    self.user = user
                } else if let user = obj.getParamValue(key: .data) as? UserProfile{
                    self.userProfile = user
                }
                if let walkId = obj.getParamValue(key: .id) as? Int{
                    self.walkId = walkId
                    self.dataProvider.requestData(q:.init(id:self.tag,type: .getWalk(walkId: walkId)))
                }
            }
        }//GeometryReader
    }//body
    
    private func movePicture(){
        guard let pictures = self.mission?.walkPath?.pictures else {return}
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.picture)
                .addParam(key: .title, value: String.pageTitle.walkPicture)
                .addParam(key: .datas, value: pictures)
        )
    }
    private func movePictureViewer(path:String?){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.pictureViewer)
                .addParam(key: .data, value:path)
        )
    }
    
    @State var userProfile:UserProfile? = nil
    @State var user:User? = nil
    @State var walkId:Int = -1
    @State var isMe:Bool = false
    @State var mission:Mission? = nil
    @State var topOffSet:CGFloat = Dimen.margin.regular
    @State var imageScale:CGFloat = 1.0
    @State var useScrollUi:Bool = false
    private func loaded(_ res:ApiResultResponds){
        guard let data = res.data as? WalkData else { return }
        self.isMe = self.dataProvider.user.isSameUser(userId: data.user?.userId)
        self.mission = Mission().setData(data, userId: self.user?.userId, isMe: self.isMe)
        self.updatedData()
    }
    
    private func updatedData(){
        guard let mission = self.mission else {return}
        self.walkId = mission.missionId
        let userId = self.user?.userId ?? self.userProfile?.userId ?? mission.userId ??  ""
        self.isMe = self.dataProvider.user.isSameUser(userId: userId)
        self.setupPictureDataSet(mission: mission)
    }
    
    @State var pictureSets:[WalkPictureItemSet] = []
    @State var pictureSize:CGSize = .zero
    private func setupPictureDataSet(mission:Mission){
        guard let pictures = mission.walkPath?.pictures else {return}
        let count:Int = 2
        self.useScrollUi = pictures.count > count
       
        let w = (self.pageSceneObserver.screenSize.width
                 - (Dimen.margin.regularExtra * CGFloat(count-1))
                 - (Dimen.app.pageHorinzontal*2)) / CGFloat(count)
        self.pictureSize = CGSize(width: w, height: w * Dimen.item.albumList.height / Dimen.item.albumList.width)
        
        var rows:[WalkPictureItemSet] = []
        var cells:[WalkPictureItem] = []
        var total = 0
        pictures.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    WalkPictureItemSet( count: count, datas: cells, isFull: true, index:total)
                )
                total += 1
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                WalkPictureItemSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.pictureSets.append(contentsOf: rows)
    }
}


#if DEBUG
struct PageWalkInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageWalkInfo().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(DataProvider())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

