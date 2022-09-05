//
//  BottomTab.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/19.
//

import Foundation
import SwiftUI
import Combine

struct PageSelecterble : SelecterbleProtocol{
    let key = UUID().uuidString
    let id:PageID
    var idx:Int = -1
    var icon:String = ""
    var text:String = ""
    var isPopup:Bool = false
}

struct BottomTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @State var pages:[PageSelecterble] = []
   
    @State var currentPageIdx:Int? = nil
    var body: some View {
        VStack{
            Spacer().modifier(LineHorizontal())
            HStack( alignment: .center, spacing:0 ){
                ForEach(self.pages, id: \.key) { gnb in
                    ImageButton(
                        isSelected:self.checkCategory(pageIdx: gnb.idx),
                        defaultImage: gnb.icon,
                        text: gnb.text,
                        defaultColor: Color.app.grey200,
                        activeColor: Color.brand.primary
                    ){ _ in
                        if gnb.isPopup {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(gnb.id)
                            )
                        } else {
                            self.pagePresenter.changePage(
                                PageProvider.getPageObject(gnb.id)
                            )
                        }
                    }
                    .modifier(MatchParent())
                }
            }
            .padding(.bottom, self.sceneObserver.safeAreaBottom)
        }
        .modifier(MatchHorizontal(height: self.sceneObserver.safeAreaBottom + Dimen.app.bottom))
        .background(Color.brand.bg)
        .onReceive (self.pagePresenter.$currentTopPage) { page in
            
            self.currentPageIdx = page?.pageIDX
        }
        .onAppear(){
            pages = [
                PageSelecterble(
                    id: .walk,
                    idx: PageProvider.getPageIdx(.walk),
                    icon: Asset.gnb.walk, text: String.gnb.walk),
                
                PageSelecterble(
                    id: .explore,
                    idx: PageProvider.getPageIdx(.explore),
                    icon: Asset.gnb.explore, text: String.gnb.explore),
                
                PageSelecterble(
                    id: .chat,
                    idx: PageProvider.getPageIdx(.chat),
                    icon: Asset.gnb.chat, text: String.gnb.chat),
               
                PageSelecterble(
                    id: .my,
                    idx: PageProvider.getPageIdx(.my),
                    icon: Asset.gnb.my, text: String.gnb.my)
            ]
        }
    }
    
    func checkCategory(pageIdx:Int) -> Bool {
        guard let currentIdx = self.currentPageIdx else { return false }
        let idx = floor( Double(pageIdx) / 100.0 )
        let cidx = floor( Double(currentIdx) / 100.0 )
        return idx == cidx
    }
}

#if DEBUG
struct ComponentBottomTab_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            BottomTab()
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width:370,height:200)
        }
    }
}
#endif
