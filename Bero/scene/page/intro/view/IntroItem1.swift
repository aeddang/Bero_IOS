//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//
import Foundation
import SwiftUI

struct IntroItem1: PageComponent, Identifiable {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    let id = UUID().uuidString
    
    var body: some View {
        ZStack(){
            Spacer().modifier(MatchParent())
            
            Image(Asset.intro.onboarding_img_1)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 270, height: 425)
            
        }
        .modifier(MatchParent())
        .background(Color.app.white)
    }
}




#if DEBUG
struct IntroItem1_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            IntroItem1().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .frame(width: 325, height: 640, alignment: .center)
        }
    }
}
#endif

