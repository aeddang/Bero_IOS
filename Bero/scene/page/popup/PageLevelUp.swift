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
                ZStack(alignment: .center){
                    if let icon = self.lv?.icon {
                        if self.isEffect {
                            LottieView(lottieFile: "levelup", mode: .playOnce)
                        }
                        Image(icon)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 90)
                            .padding(.bottom, 260)
                    }
                    if let lvValue = self.lvValue {
                        Text(lvValue)
                            .modifier(BoldTextStyle(
                                size: Font.size.black,
                                color: Color.app.white
                            ))
                            .padding(.bottom, 240)
                    }
                }
                .padding(.bottom, 50)
                VStack(spacing:0){
                    Text(String.pageText.levelUpText)
                        .modifier(BoldTextStyle(
                            size: Font.size.black,
                            color: Color.app.white
                        ))
                        .padding(.top, Dimen.margin.medium)
                    
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
                let prev = lv-1
                self.prevLv = Lv.prefix +  prev.description
                self.currentLv = Lv.prefix + lv.description
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                    withAnimation{
                        self.color = Lv.getLv(prev).color
                        self.lv = Lv.getLv(prev)
                        self.lvValue = prev.description
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5){
                    withAnimation{
                        self.color = Lv.getLv(lv).color
                        self.lv = Lv.getLv(lv)
                        self.lvValue = lv.description
                    }
                    self.isEffect = true
                }
            }
            .onDisappear{
               
            }
            
        }//geo
    }//body
    @State var lvValue:String? = nil
    @State var lv:Lv? = nil
    @State var prevLv:String = ""
    @State var currentLv:String = ""
    @State var color:Color = Color.app.white
    @State var isEffect:Bool = false
   
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

 
