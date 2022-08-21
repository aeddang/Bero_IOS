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
                            type: mission.type,
                            title: (mission.title ?? "mission") + " complete",
                            text: mission.viewDuration + "/"  + mission.viewDistance,
                            point: mission.point,
                            action : {
                                self.sendResult()
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
                    
                default : break
                }
            }
        }//geo
    }//body
   
    @State var mission:Mission? = nil
    @State var withProfiles:[PetProfile] = []
    @State var resultMissionId:Int? = nil
   
    private func sendResult(){
        guard let mission = self.mission else { return }
        self.dataProvider.requestData(q: .init(id:self.tag, type: .completeMission(mission, self.withProfiles), isLock: true))
        
    }
    
    private func closeMission(){
        if let mission = self.mission {
            self.walkManager.endMission(missionId: self.resultMissionId)
            self.dataProvider.user.missionCompleted(mission)
        }
        if self.resultMissionId != nil {
            self.appSceneObserver.event = .toast(String.pageText.missionCompletedSaved)
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

 
