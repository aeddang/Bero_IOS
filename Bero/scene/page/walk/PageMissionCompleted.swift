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

struct PageMissionCompleted: PageView {
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
                            title: "mission complete",
                            text: mission.viewPlayTime + "/"  + mission.viewPlayDistance,
                            point: mission.lv.point,
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
                self.mission = self.walkManager.currentMission
                let datas = self.dataProvider.user.pets.filter{$0.isWith}
                self.withProfiles = datas
            }
            .onDisappear{
               
            }
            .onReceive(self.appSceneObserver.$pickImage) { pick in
                guard let pick = pick else {return}
                if pick.id?.hasSuffix(self.tag) != true {return}
                if let img = pick.image {
                    self.pagePresenter.isLoading = true
                    DispatchQueue.global(qos:.background).async {
                        let uiImage = img.normalized().centerCrop().resize(to: CGSize(width: 240,height: 240))
                        DispatchQueue.main.async {
                            self.pagePresenter.isLoading = false
                            self.checkResult(img: uiImage)
                        }
                    }
                }
            }
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .completeMission : self.onClose()
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
    @State var resultImage:String? = nil
    private func pickImage(_ img:UIImage) {
        self.pagePresenter.isLoading = true
        DispatchQueue.global(qos:.background).async {
            let uiImage = img.normalized().centerCrop().resize(to: CGSize(width: 240,height: 240))
            DispatchQueue.main.async {
                self.pagePresenter.isLoading = false
                self.checkResult(img: uiImage)
            }
        }
    }
    
    private func checkResult(img:UIImage){
        self.dataProvider.requestData(q: .init(id:self.tag, type: .checkHumanWithDog(img), isLock: true))
        
    }
    private func sendResult(imgPath:String?){
        self.resultImage = imgPath
        guard let mission = self.mission else { return }
        self.dataProvider.requestData(q: .init(id:self.tag, type: .completeMission(mission, self.withProfiles), isLock: true))
        
    }
    private func onClose(){
        if let mission = self.mission {
            self.dataProvider.user.missionCompleted(mission)
        }
        self.closeMission()
    }
    private func closeMission(){
        self.walkManager.endMission(imgPath: self.resultImage)
        if self.resultImage != nil {
            self.appSceneObserver.event = .toast(String.pageText.missionCompletedSaved)
        }
        self.pagePresenter.closeAllPopup()
    }

}


#if DEBUG
struct PageMissionCompleted_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMissionCompleted().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

 
