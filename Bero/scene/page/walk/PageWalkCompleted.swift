//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps

struct PageWalkCompleted: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver

    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                Spacer().modifier(MatchParent())
            }
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .completeWalk :
                    self.appSceneObserver.alert  = .confirm(nil, String.alert.completedAndMoveHistoryConfirm){ isOk in
                        if isOk {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.walkHistory)
                                    .addParam(key: .data, value: self.dataProvider.user)
                                    .addParam(key: .isInitAction, value: true)
                            )
                        }
                        self.closePopup()
                    }
                    
                default : break
                }
            }
            .onReceive(self.dataProvider.$error){ err in
                guard let err = err else { return }
                if !err.id.hasPrefix(self.tag) {return}
                switch err.type {
                case .completeWalk:
                    self.pagePresenter.isLoading = false
                    self.pagePresenter.closePopup(self.pageObject?.id)
                    
                default : break
                }
            }
            .onAppear{
                self.mission = self.walkManager.completedWalk
                self.openPicker()
            }
            .onDisappear{
               
            }
            
        }//geo
    }//body
    
    private func openPicker(){
        self.appSceneObserver.event = .openImagePicker(self.tag, type: .camera, cameraDevice: .rear){ img in
            guard let img = img else {
                self.pagePresenter.closePopup(self.pageObject?.id)
                return
            }
            self.pickImage(img)
        }
    }
    

    @State var mission:Mission? = nil
    private func pickImage(_ img:UIImage) {
        self.pagePresenter.isLoading = true
        DispatchQueue.global(qos:.background).async {
            let size = CGSize(
                width: AlbumApi.originSize,
                height: AlbumApi.originSize)
            let image = img.normalized().crop(to: size).resize(to: size)
            
            let sizeList = CGSize(
                width: AlbumApi.thumbSize,
                height: AlbumApi.thumbSize)
            let thumbImage = img.normalized().crop(to: sizeList).resize(to: sizeList)
            DispatchQueue.main.async {
                self.sendResult(img: image, thumbImage: thumbImage)
            }
        }
    }
    
    private func sendResult(img:UIImage, thumbImage:UIImage){
        guard let mission = self.mission else { return }
        guard let loc = mission.location else { return }
        self.dataProvider.requestData(q:
                .init(id: self.tag, type: .completeWalk(
                    walkId: mission.missionId, loc: loc,
                    additionalData: .init(
                        img: img, thumbImg: thumbImage,
                        walkTime: mission.duration, walkDistance: mission.distance
                    )
                )))
    }
    
    private func closePopup(){
        self.pagePresenter.isLoading = false
        self.walkManager.endWalk()
        self.repository.updateTodayWalkCount()
        if let mission = self.mission {
            self.dataProvider.user.missionCompleted(mission)
        }
        self.pagePresenter.closePopup(self.pageObject?.id)
    }

}


#if DEBUG
struct PageWalkCompleted_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageWalkCompleted().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

 
