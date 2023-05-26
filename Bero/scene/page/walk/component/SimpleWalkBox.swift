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
    @EnvironmentObject var pagePresenter:PagePresenter
    var body: some View {
        ZStack(alignment: .top){
            FillButton(
                type: .fill,
                icon: Asset.icon.paw,
                text: WalkManager.viewDistance(self.walkDistance),
                size: Dimen.button.regularExtra,
                color: Color.app.black,
                isActive: true
            ){_ in
                if self.pagePresenter.currentPage?.pageID == PageID.walk {
                    self.pagePresenter.closeAllPopup()
                    self.walkManager.updateSimpleView(false)
                } else {
                    
                    self.pagePresenter.changePage(PageProvider.getPageObject(.walk))
                }
                //self.finishWalk()
            }
            .frame(width: 115)
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
        .onReceive(self.walkManager.$walkDistance){ distance in
            self.walkDistance = distance
        }
        
        
    }
    @State var walkDistance:Double = 0
    private func finishWalk(){
        self.appSceneObserver.sheet = .select(
            String.pageText.walkFinishConfirm,
            nil,
            [String.app.cancel,String.button.finish]){ idx in
                if idx == 1 {
                    self.walkManager.completeWalk()
                }
            }
    }

}


