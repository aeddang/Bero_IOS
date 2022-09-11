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

extension SimpleWalkBox {
    static let offset:CGFloat = Dimen.radius.light
}

struct SimpleWalkBox: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var walkManager:WalkManager
    var body: some View {
        ZStack(alignment: .top){
            FillButton(
                type: .fill,
                icon: Asset.icon.play_circle_filled,
                text: String.button.finish,
                size: Dimen.button.regularExtra,
                color: Color.app.black,
                isActive: true
            ){_ in
                self.finishWalk()
            }
            .frame(width: 95)
        }
        .padding(.leading, Dimen.margin.tiny + Self.offset)
        .padding(.trailing, Dimen.margin.tiny)
        .padding(.vertical, Dimen.margin.tiny)
        .background(Color.app.white )
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
        .overlay(
            RoundedRectangle(cornerRadius: Dimen.radius.light)
                .strokeBorder(
                    Color.app.grey100,
                    lineWidth: Dimen.stroke.light
                )
        )
       
    }
    
    private func finishWalk(){
        if self.walkManager.currentMission != nil {
            self.appSceneObserver.alert = .confirm("수행중 미션 있음", "수행중이던 미션은 종료됩니다"){ isOk in
                if isOk {
                    self.walkManager.endMission()
                    self.finishWalk()
                }
            }
            return
        }
        self.appSceneObserver.alert = .confirm(nil, "산책을 종료 하겠습니까? 1초(테스트) 이상 산책해야 저장됩니다."){ isOk in
            if isOk {
                if self.walkManager.walkTime >= 1 {
                    self.walkManager.completeWalk()
                } else {
                    self.walkManager.endWalk()
                }
            }
        }
    }

}


