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
        VStack(alignment: .leading, spacing: 0){
            HStack{
                Image(Asset.image.dog1)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 206, height: 151)
                    .padding(.leading, -12)
                Spacer()
            }
            Text(String.pageText.introText1_1)
                .modifier(BoldTextStyle(size: Font.size.black, color: Color.app.black))
                .padding(.leading, Dimen.margin.regular)
                .padding(.top, Dimen.margin.medium)
                .fixedSize(horizontal: false, vertical: true)
            Text(String.pageText.introText1_2)
                .modifier(MediumTextStyle(size: Font.size.light, color: Color.app.black))
                .padding(.leading, Dimen.margin.regular)
                .padding(.top, Dimen.margin.regular)
                .fixedSize(horizontal: false, vertical: true)
            HStack{
                Spacer()
                Image(Asset.image.dog2)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.trailing, -88)
                    .padding(.top, Dimen.margin.medium)
                    .frame(width: 269, height: 135)
            }
            Spacer().frame(height: Dimen.margin.heavy)
        }
        .modifier(MatchParent())
        .background(Color.init(rgb:0xFFA451))
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

