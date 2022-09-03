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
                ZStack(alignment: .topLeading){
                    if let mission = self.mission {
                        RedeemInfo(
                            type: mission.type,
                            title: (mission.title ?? "Walk") + " complete",
                            text: mission.viewDuration + "/"  + mission.viewDistance,
                            point: mission.point,
                            action : {
                                self.appSceneObserver.alert = .alert(nil, String.alert.completedNeedPicture){
                                    self.appSceneObserver.event = .openImagePicker(self.tag, type: .photoLibrary){ img in
                                        guard let img = img else {return}
                                        self.pickImage(img)
                                    }
                                }
                            },
                            close: {
                                self.appSceneObserver.alert = .confirm(nil, String.alert.completedExitConfirm){ isOk in
                                    if isOk {
                                        self.closeMission()
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.all, Dimen.margin.regular)
                .modifier(MatchParent())
                .background(Color.transparent.black70)
                //.modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            .onAppear{
                self.mission = self.walkManager.completedWalk
                let datas = self.dataProvider.user.pets.filter{$0.isWith}
                self.withProfiles = datas
            }
            .onDisappear{
               
            }
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .completeMission :
                    guard let data = res.data as? MissionData else {
                        self.appSceneObserver.event = .toast(String.alert.completedError)
                        return
                    }
                    self.resultMissionId = data.missionId
                    self.closeMission()
                    
                case .checkHumanWithDog :
                    guard let data = res.data as? DetectData else {
                        self.appSceneObserver.event = .toast(String.alert.completedNeedPictureError)
                        return
                    }
                    if data.isDetected != true {
                        self.appSceneObserver.event = .toast(String.alert.completedNeedPictureError)
                        return
                    }
                    self.sendResult(imgPath: data.pictureUrl)
                default : break
                }
            }
        }//geo
    }//body
   
    @State var mission:Mission? = nil
    @State var withProfiles:[PetProfile] = []
    @State var resultMissionId:Int? = nil
    @State var resultImage:String? = nil
    private func pickImage(_ img:UIImage) {
        self.pagePresenter.isLoading = true
        DispatchQueue.global(qos:.background).async {
            let scale:CGFloat = 1.0 //UIScreen.main.scale
            let size = CGSize(
                width: AlbumApi.originSize * scale,
                height: AlbumApi.originSize * scale)
            let image = img.normalized().crop(to: size).resize(to: size)
            
            let sizeList = CGSize(
                width: AlbumApi.thumbSize * scale,
                height: AlbumApi.thumbSize * scale)
            let thumbImage = img.normalized().crop(to: sizeList).resize(to: size)
            DispatchQueue.main.async {
                self.pagePresenter.isLoading = false
                self.checkResult(img: image, thumb:thumbImage)
            }
        }
    }
    
    private func checkResult(img:UIImage, thumb:UIImage){
        self.dataProvider.requestData(q: .init(id:self.tag, type: .checkHumanWithDog(img:img, thumbImg: thumb), isLock: true))
        
    }
    private func sendResult(imgPath:String?){
        self.resultImage = imgPath
        guard let mission = self.mission else { return }
        self.dataProvider.requestData(q: .init(id:self.tag, type: .completeMission(mission, self.withProfiles, image: self.resultImage), isLock: true))
        
    }
    
    private func closeMission(){
        self.walkManager.endWalk()
        if let mission = self.mission {
            self.dataProvider.user.missionCompleted(mission)
        }
        if self.resultMissionId != nil {
            self.appSceneObserver.event = .toast(String.pageText.missionCompletedSaved)
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

 
