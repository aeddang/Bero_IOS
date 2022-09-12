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

struct StartBox: PageComponent{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    var body: some View {
        ZStack(alignment: .top){
            HStack(spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
            }
            VStack(alignment: .leading, spacing:Dimen.margin.thin){
                Text(self.title)
                    .modifier(SemiBoldTextStyle(
                        size: Font.size.medium,
                        color: Color.app.grey500
                    ))
                LocationInfo()
                FillButton(
                    type: .fill,
                    text: String.button.startWalking,
                    size: Dimen.button.regular,
                    color: Color.brand.primary,
                    isActive: true
                ){_ in
                    self.startWalk()
                }
            }
        }
        .padding(.all, Dimen.margin.regularExtra)
        .background(Color.app.white )
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
        .overlay(
            RoundedRectangle(cornerRadius: Dimen.radius.light)
                .strokeBorder(
                    Color.app.grey100,
                    lineWidth: Dimen.stroke.light
                )
        )
        .modifier(ShadowLight( opacity: 0.05 ))
        .onReceive(self.walkManager.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedMissions : self.checkMissionComplete()
            case .endMission : self.checkMissionComplete()
            default: break
            }
        }
        .onAppear(){
            self.checkMissionComplete()
        }
    }
    
    @State var title:String = ""
    private func checkMissionComplete(){
        if WalkManager.todayWalkCount == 0 {
            self.title = String.pageText.walkNoWalksText
        } else {
            let count = self.walkManager.missions.filter{$0.isCompleted}.count
            let pre = count == 0 ? "No" : count.description
            self.title = String.pageText.walkMissionCompletedText.replace(pre)
        }
        
    }
   
    private func startWalk(){
        if  self.walkManager.currentLocation == nil {
            self.appSceneObserver.event = .toast(String.pageText.walkLocationNotFound)
            return
        }
        if PageChooseDog.isFirstChoose && self.dataProvider.user.pets.count >= 2 {
            self.pagePresenter.openPopup(PageProvider.getPageObject(.chooseDog))
            return
        }
        self.walkManager.startWalk()
    }
}



#if DEBUG
struct StartBox_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            StartBox(
            
            )
        }
        .padding(.all, 10)
        .background(Color.app.white)
    }
}
#endif
