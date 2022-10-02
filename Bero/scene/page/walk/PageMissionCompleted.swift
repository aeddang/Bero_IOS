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
                Spacer().modifier(MatchParent())
                //.modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .completeMission :
                    guard let data = res.data as? MissionData else {
                        self.appSceneObserver.event = .toast(String.alert.completedError)
                        self.openSheet(isRetry: true)
                        return
                    }
                    self.resultMissionId = data.missionId
                    self.closeMission()
                    
                default : break
                }
            }
            .onReceive(self.dataProvider.$error){ err in
                guard let err = err else { return }
                if !err.id.hasPrefix(self.tag) {return}
                switch err.type {
                case .completeMission : self.openSheet(isRetry: true)
                default : break
                }
            }
            .onAppear{
                self.mission = self.walkManager.currentMission
                self.openSheet()
            
            }
            .onDisappear{
               
            }
            
        }//geo
    }//body
   
    @State var mission:Mission? = nil
    @State var resultMissionId:Int? = nil
    
    private func openSheet(isRetry:Bool = false){
        if isRetry {
            self.appSceneObserver.sheet = .confirm(
                String.pageText.missionSuccessTitle,
                String.pageText.missionSuccessText.replace(mission?.place?.name ?? "Mission"),
                point: self.mission?.point,
                exp: self.mission?.exp) { isOk in
                    if isOk {
                        self.sendResult()
                    } else {
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                }
        } else {
            self.appSceneObserver.sheet = .alert(
                String.pageText.missionSuccessTitle,
                String.pageText.missionSuccessText.replace(mission?.place?.name ?? "Mission"),
                point: self.mission?.point,
                exp: self.mission?.exp,
                confirm: String.button.redeemReward) {
                    self.sendResult()
                }
        }
    }
   
    private func sendResult(){
        guard let mission = self.mission else { return }
        let withProfiles = self.dataProvider.user.pets.filter{$0.isWith}
        self.dataProvider.requestData(q: .init(id:self.tag, type: .completeMission(mission, withProfiles), isLock: true))
        
    }
    
    private func closeMission(){
        if let mission = self.mission {
            self.walkManager.endMission(missionId: self.resultMissionId)
            self.dataProvider.user.missionCompleted(mission)
        }
        self.pagePresenter.closePopup(self.pageObject?.id)
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

 
