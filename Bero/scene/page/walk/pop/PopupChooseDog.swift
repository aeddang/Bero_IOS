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

struct PopupChooseDog: PageView {
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
                ZStack(alignment: .bottom){
                    Button(action: {
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }) {
                       Spacer().modifier(MatchParent())
                           .background(Color.transparent.clearUi)
                    }
                    VStack(alignment: .leading, spacing: Dimen.margin.medium){
                        VStack(alignment: .leading, spacing: Dimen.margin.tinyExtra){
                            Text(String.pageText.walkStartChooseDogTitle)
                                .modifier(BoldTextStyle(
                                    size: Font.size.medium,
                                    color: Color.app.black
                                ))
                            Text(String.pageText.walkStartChooseDogText)
                                .modifier(RegularTextStyle(
                                    size: Font.size.thin,
                                    color: Color.app.grey400
                                ))
                            
                        }
                        VStack (alignment: .leading, spacing: Dimen.margin.tiny){
                            ForEach(self.pets) { pet in
                                PetProfileCheckItem(profile: pet)
                            }
                        }
                        HStack(spacing: Dimen.margin.tinyExtra){
                            FillButton(type: .fill,
                                       text: String.app.cancel,
                                       color:Color.app.grey50,
                                       textColor: Color.app.grey400){ _ in
                                self.pagePresenter.closePopup(self.pageObject?.id)
                            }
                            
                            FillButton(type: .fill, text: String.button.startWalking,
                                       color:  Color.app.white,
                                       gradient:Color.app.orangeGradient)
                            { _ in
                                self.startWalk()
                                
                            }
                            .opacity(self.pets.first(where: {$0.isWith}) == nil ? 0.3 : 1)
                        }
                    }
                    .padding(.bottom, self.appSceneObserver.safeBottomHeight)
                    .modifier(BottomFunctionTab())
                    .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                }
            }
            .onAppear{
                self.pets = self.dataProvider.user.pets
            }
            
        }//geo
    }//body
    
    @State var pets:[PetProfile] = []
    private func startWalk(){
        if self.pets.first(where: {$0.isWith}) == nil {return}
        self.walkManager.requestWalk()
        self.pagePresenter.closePopup(self.pageObject?.id)
    }
    
}


#if DEBUG
struct PageChooseDog_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PopupChooseDog().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

 
