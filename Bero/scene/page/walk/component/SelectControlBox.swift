//
//  ComponentTabNavigation.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct SelectControlBox : PageComponent {
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
   
    var body: some View {
        ZStack(alignment: .topTrailing){
            Spacer().modifier(MatchParent())
            ImageButton( defaultImage: Asset.icon.close){ _ in
                self.close()
            }
            ZStack{
                if let mission = self.mission {
                    MissionControl(
                        pageObservable: self.pageObservable,
                        viewModel:self.viewModel,
                        data: mission){
                        
                        self.close()
                    }
                }
                if let mission = self.user {
                    UserControl(
                        pageObservable: self.pageObservable,
                        viewModel:self.viewModel,
                        data: mission){
                        self.close()
                    }
                }
                if let place = self.place {
                    PlaceControl(
                        pageObservable: self.pageObservable,
                        viewModel:self.viewModel,
                        data: place){
                        self.close()
                    }
                }
            }
            .padding(.top, Dimen.margin.regular)
        }
        .padding(.all, Dimen.margin.thin)
        .modifier(MatchHorizontal(height: 120))
        .background(Color.app.whiteDeep)
        .opacity(self.isShowing ? 1 : 0)
        .onReceive(self.viewModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .tabMarker(let marker) :
                self.reset()
                DispatchQueue.main.async {
                    if let mission = marker.userData as? Mission {
                        switch mission.type {
                        case .new :
                            self.changeMissionStatus(mission)
                        case .user :
                            self.changeUserStatus(mission)
                        default : break
                        }
                    } else if let place = marker.userData as? Place {
                        self.changePlaceStatus(place)
                    }
                    let willShowing =  self.place != nil || self.user != nil || self.mission != nil
                    if willShowing == self.isShowing {return}
                    withAnimation{
                        self.isShowing = willShowing
                    }
                }
            }
        }
        .onAppear{
            if let mission = self.walkManager.currentMission {
                self.mission =  mission
                withAnimation{
                    self.isShowing = true
                }
            }
        }
        
    }//body
    @State var isShowing:Bool = false
    @State var mission:Mission? = nil
    @State var place:Place? = nil
    @State var user:Mission? = nil
    private func reset(){
        self.mission = nil
        self.place = nil
        self.user = nil
    }
    private func close(){
        self.reset()
        withAnimation{
            self.isShowing = false
        }
    }
    
    private func changeMissionStatus(_ mission:Mission){
        if mission.isSelected {
            if self.mission == mission {return}
            self.reset()
            self.mission = mission
        } else if mission == self.mission {
            self.mission = nil
        }
    }
    
    private func changeUserStatus(_ mission:Mission){
        if mission.isSelected {
            if self.user == mission {return}
            self.reset()
            self.user = mission
        } else if mission == self.user {
            self.user = nil
        }
    }
    
    private func changePlaceStatus(_ place:Place){
        if place.isSelected {
            if self.place == place {return}
            self.reset()
            self.place = place
        } else if place == self.place {
            self.place = nil
        }
    }
}

#if DEBUG
struct SelectControlBox_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SelectControlBox(
                
            )
            .frame( alignment: .center)
        }
        .background(Color.app.white)
        .environmentObject(AppSceneObserver())
        .environmentObject(WalkManager(dataProvider: DataProvider(), locationObserver: LocationObserver()))
        .environmentObject(DataProvider())
    }
}
#endif
