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

struct PageAlbum: PageView {
    enum ViewType{
        case info, album
    }
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var repository:Repository
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    let buttons = [String.button.information, String.button.album]
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(alignment: .leading, spacing: 0 ){
                    TitleTab(
                        infinityScrollModel: self.infinityScrollModel,
                        title:String.button.album,
                        useBack:true,
                        buttons: self.user?.isMe == true ? [.add,.setting] : []){ type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            case .add :
                                self.onPick()
                            case .setting :
                                withAnimation{
                                    self.isEdit.toggle()
                                }
                            default : break
                            }
                        }
                    if let user = self.user {
                        AlbumList(
                            pageObservable: self.pageObservable,
                            infinityScrollModel: self.infinityScrollModel,
                            type:.detail,
                            user:user,
                            pet:self.pet,
                            initId: self.initId,
                            listSize: geometry.size.width,
                            isEdit: self.$isEdit
                        )
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let user = obj.getParamValue(key: .data) as? User{
                    self.user = user
                }
                if let pet = obj.getParamValue(key: .subData) as? PetProfile{
                    self.pet = pet
                }
                if let initId = obj.getParamValue(key: .id) as? Int{
                    self.initId = initId
                }
                if let id = self.pet?.petId {
                    self.currentId = id.description
                    self.currentType = .pet
                } else {
                    self.currentId = self.user?.snsUser?.snsID ?? ""
                    self.currentType = .user
                }
            }
        }//GeometryReader
    }//body
    @State var user:User? = nil
    @State var isEdit:Bool = false
    @State var pet:PetProfile? = nil
    @State var initId:Int? = nil
    @State var currentId:String = ""
    @State var currentType:AlbumApi.Category = .user
    private func onPick(){
        self.appSceneObserver.select = .imgPicker(self.tag){ pick in
            guard let pick = pick else {return}
            DispatchQueue.global(qos:.background).async {
                let scale:CGFloat = 1 //UIScreen.main.scale
                let sizeList = CGSize(
                    width: AlbumApi.thumbSize * scale,
                    height: AlbumApi.thumbSize * scale)
                let thumbImage = pick.normalized().crop(to: sizeList).resize(to: sizeList)
                DispatchQueue.main.async {
                    self.pagePresenter.isLoading = false
                    self.updateConfirm(img:pick, thumbImage:thumbImage)
                }
            }
           
        }
    }
    
    private func updateConfirm(img:UIImage, thumbImage:UIImage){
        var isExpose = self.repository.storage.isExpose
        if self.repository.storage.isExposeSetup {
            self.update(img: img, thumbImage: thumbImage, isExpose:isExpose)
        } else {
            self.appSceneObserver.alert = .confirm(nil, String.alert.exposeConfirm){ isOk in
                isExpose = isOk
                self.update(img: img, thumbImage: thumbImage, isExpose:isExpose)
            }
        }
    }
    private func update(img:UIImage, thumbImage:UIImage, isExpose:Bool){
        
        self.dataProvider.requestData(q: .init(
            id: self.currentId,
            type: .registAlbumPicture(img: img, thumbImg: thumbImage, userId: self.currentId, self.currentType, isExpose: isExpose)
        ))
    }
}


#if DEBUG
struct PageAlbum_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageAlbum().contentBody
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

