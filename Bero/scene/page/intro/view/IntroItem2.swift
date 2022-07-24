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
        VStack(alignment: .leading, spacing: 0){
            HStack{
                Spacer()
                Image(Asset.image.dog3)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 240, height: 165)
                    .padding(.trailing, -15)
            }
            Text(String.pageText.introText2_1)
                .modifier(BoldTextStyle(size: Font.size.bold, color: Color.app.black))
                .padding(.leading, Dimen.margin.regular)
                .padding(.top, Dimen.margin.medium)
                .fixedSize(horizontal: false, vertical: true)
            Text(String.pageText.introText2_2)
                .modifier(MediumTextStyle(size: Font.size.light, color: Color.app.black))
                .padding(.leading, Dimen.margin.regular)
                .padding(.top, Dimen.margin.regular)
                .fixedSize(horizontal: false, vertical: true)
            HStack{
                Image(Asset.image.dog4)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, Dimen.margin.medium)
                    .frame(width: 232, height: 165)
                    .padding(.leading, -30)
                Spacer()
            }
            Spacer().frame(height: Dimen.margin.heavy)
        }
        .modifier(MatchParent())
        .background(Color.app.orangeExtra)
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

