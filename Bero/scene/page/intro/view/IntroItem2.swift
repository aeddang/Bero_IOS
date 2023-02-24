//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//
import Foundation
import SwiftUI

struct IntroItem2: PageComponent, Identifiable {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    let id = UUID().uuidString
    
    var body: some View {
        ZStack(alignment: .trailing){
            Spacer().modifier(MatchParent())
            LottieView(lottieFile: Asset.intro.onboarding_ani_1, autoPlay: false)
            .modifier(MatchParent())
            /*
            Image(Asset.intro.onboarding_img_2)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 339, height: 417)
                .padding(.trailing,-10)
             */
        }
        .modifier(MatchParent())
        .background(Color.app.white)
    }
}




#if DEBUG
struct IntroItem2_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            IntroItem2().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .frame(width: 325, height: 640, alignment: .center)
        }
    }
}
#endif

