//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Foundation
import SwiftUI
struct SceneTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
   
    @State var positionBottom:CGFloat = -Dimen.app.bottom
    @State var isDimed:Bool = false
    @State var isLoading:Bool = false
    @State var safeAreaTop:CGFloat = 0
    @State var safeAreaBottom:CGFloat = 0
    @State var useBottom:Bool = false
   
   
    var body: some View {
        ZStack{
            VStack(spacing:Dimen.margin.regular){
                Spacer()
                if self.isLoading {
                    ActivityIndicator(isAnimating: self.$isLoading)
                }
                BottomTab()
                    .padding(.bottom, self.positionBottom)
                    .opacity(self.useBottom ? 1 : 0)
            }
            if self.isDimed {
                Button(action: {
                    self.appSceneObserver.cancelAll()
                }) {
                    Spacer().modifier(MatchParent())
                        .background(Color.transparent.black45)
                }
            }
        }
        .modifier(MatchParent())
        .onReceive (self.appSceneObserver.$isApiLoading) { loading in
            DispatchQueue.main.async {
                withAnimation{
                    self.isLoading = loading
                }
            }
        }
        .onReceive (self.sceneObserver.$safeAreaTop){ pos in
            if self.safeAreaTop != pos {
                self.safeAreaTop = pos
            }
        }
        .onReceive (self.sceneObserver.$safeAreaBottom){ pos in
            if self.safeAreaBottom != pos {
                self.safeAreaBottom = pos
                self.updateBottomPos()
            }
        }
        .onReceive (self.appSceneObserver.$useBottom) { use in
            withAnimation{
                self.useBottom = use
            }
            self.updateBottomPos()
        }
       
        .onReceive (self.appSceneObserver.$useBottomImmediately) { use in
            self.useBottom = use
            self.updateBottomPos()
        }
        
    }
    
    func updateBottomPos(){
        withAnimation{
            self.positionBottom = self.appSceneObserver.useBottom
                ? 0
                : -(Dimen.app.bottom+self.safeAreaBottom)
        }
    }
    
    
    
}

#if DEBUG
struct SceneTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SceneTab()
            .environmentObject(AppObserver())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(PagePresenter())
                .frame(width:340,height:300)
        }
    }
}
#endif
