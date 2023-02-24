//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//
import Foundation
import SwiftUI

struct IntroItem3: PageComponent, Identifiable {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    let id = UUID().uuidString
    
    var body: some View {
        ZStack(alignment: .leading){
            Spacer().modifier(MatchParent())
            LottieView(lottieFile: Asset.intro.onboarding_ani_2, autoPlay: false)
            .modifier(MatchParent())
            /*
            Image(Asset.intro.onboarding_img_3)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 331, height: 403)
             */
        }
        .modifier(MatchParent())
        .background(Color.app.white)
    }
}


#if DEBUG
struct IntroItem3_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            IntroItem3().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .frame(width: 325, height: 640, alignment: .center)
        }
    }
}
#endif

