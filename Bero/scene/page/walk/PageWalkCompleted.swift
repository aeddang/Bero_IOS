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
                case .completeMission :
                    guard let data = res.data as? MissionData else {
                        self.appSceneObserver.event = .toast(String.alert.completedError)
                        self.pictureCheckSuccess(imgPath: self.resultImage, isRetry: true)
                        return
                    }
                    self.resultMissionId = data.missionId
                    self.closeMission()
                    
                case .checkHumanWithDog :
                    guard let data = res.data as? DetectData else {
                        self.pictureCheckFail()
                        return
                    }
                    if data.isDetected != true {
                        self.pictureCheckFail()
                        return
                    }
                    self.pictureCheckSuccess(imgPath: data.pictureUrl)
                default : break
                }
            }
            .onReceive(self.dataProvider.$error){ err in
                guard let err = err else { return }
                if !err.id.hasPrefix(self.tag) {return}
                switch err.type {
                case .completeMission :
                    self.pictureCheckSuccess(imgPath: self.resultImage, isRetry: true)
                    
                case .checkHumanWithDog :
                    self.pictureCheckFail()
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
    
    private func pictureCheckSuccess(imgPath:String?, isRetry:Bool = false){
        guard let mission = self.mission else { return }
        self.resultImage = imgPath
        let firstPet = self.dataProvider.user.pets.filter{$0.isWith}.first
        let point = mission.point
        let exp = mission.exp
        if isRetry {
            self.appSceneObserver.sheet = .confirm(
                String.pageText.walkFinishSuccessTitle,
                firstPet == nil ? nil : String.pageText.walkFinishSuccessText.replace(firstPet?.name ?? ""),
                point:point,
                exp:exp
            ) { isOk in
                    if isOk {
                        self.sendResult()
                    } else {
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                }
        } else {
            self.appSceneObserver.sheet = .alert(
                String.pageText.walkFinishSuccessTitle,
                firstPet == nil ? nil : String.pageText.walkFinishSuccessText.replace(firstPet?.name ?? ""),
                point:point,
                exp:exp,
                confirm: String.button.accepAndClose) {
                    self.sendResult()
                }
        }
        
    }
    
    private func pictureCheckFail(){
        self.appSceneObserver.sheet = .alert(
            String.pageText.walkFinishFailTitle,
            String.pageText.walkFinishFailText,
            confirm: String.button.takeAnotherPhoto) {
                self.sendResult()
            }
    }
    
    @State var mission:Mission? = nil
    @State var resultMissionId:Int? = nil
    @State var resultImage:String? = nil
    private func pickImage(_ img:UIImage) {
        self.pagePresenter.isLoading = true
        DispatchQueue.global(qos:.background).async {
            let scale:CGFloat = 1 //UIScreen.main.scale
            let size = CGSize(
                width: AlbumApi.originSize * scale,
                height: AlbumApi.originSize * scale)
            let image = img.normalized().crop(to: size).resize(to: size)
            
            let sizeList = CGSize(
                width: AlbumApi.thumbSize * scale,
                height: AlbumApi.thumbSize * scale)
            let thumbImage = img.normalized().crop(to: sizeList).resize(to: sizeList)
            DispatchQueue.main.async {
                self.pagePresenter.isLoading = false
                self.checkResult(img: image, thumb:thumbImage)
            }
        }
    }
    
    private func checkResult(img:UIImage, thumb:UIImage){
        self.dataProvider.requestData(q: .init(id:self.tag, type: .checkHumanWithDog(img:img, thumbImg: thumb), isLock: true))
        
    }
    
    private func sendResult(){
        guard let imgPath = self.resultImage else { return }
        guard let mission = self.mission else { return }
        let withProfiles = self.dataProvider.user.pets.filter{$0.isWith}
        self.dataProvider.requestData(q: .init(id:self.tag, type: .completeMission(mission, withProfiles, image: imgPath), isLock: true))
    }
    
    private func closeMission(){
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

 
