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

struct PageLevelUp: PageView {
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
                    .background(Color.transparent.black80)
                //
                VStack(spacing:0){
                    Image(Asset.image.puppy)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 170)
                    
                    Text(String.pageText.levelUpText)
                        .modifier(BoldTextStyle(
                            size: Font.size.black,
                            color: Color.app.white
                        ))
                        .padding(.top, Dimen.margin.heavyExtra)
                    
                    ChangeBox(
                        prev: self.prevLv,
                        next: self.currentLv,
                        activeColor: self.color
                    )
                    .padding(.top, Dimen.margin.regularUltra)
                    
                    FillButton(
                        type: .fill,
                        text: String.app.confirm,
                        size: Dimen.button.regular,
                        color:  Color.app.white,
                        gradient:Color.app.orangeGradient,
                        isActive: true
                    ){_ in
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                    .frame(width:164, height: Dimen.button.medium)
                    .padding(.top, Dimen.margin.mediumUltra)
                }
            }
            .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            .onAppear{
                let lv = self.dataProvider.user.lv
                self.prevLv = Lv.prefix + (lv-1).description
                self.currentLv = Lv.prefix + lv.description
                self.color = Lv.getLv(lv).color
            }
            .onDisappear{
               
            }
            
        }//geo
    }//body
    @State var prevLv:String = ""
    @State var currentLv:String = ""
    @State var color:Color = Color.app.white
   
}


#if DEBUG
struct PageLevelUpCompleted_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageLevelUp().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

 
