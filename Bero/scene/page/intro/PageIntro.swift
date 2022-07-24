//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//
import Foundation
import SwiftUI

struct PageIntro: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    let pages: [PageViewProtocol] =
    [
        IntroItem1(),
        IntroItem2(),
        IntroItem3()
    ]
    @State var index: Int = 0
    @State var leading:CGFloat = 0
    @State var trailing:CGFloat = 0
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        ZStack(alignment: .bottom){
            CPImageViewPager(
                viewModel : self.viewModel,
                pages: self.pages
            )
            if self.index < (self.pages.count - 1) {
                Button(action: {
                    self.viewModel.request = .move(self.index + 1)
                }) {
                    ZStack{
                        Image(Asset.icon.arrow_right)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.light,
                                   height: Dimen.icon.light)
                        
                    }
                    .frame(width: 76, height: 57)
                    .background(Color.app.white)
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
                    .modifier(Shadow())
                    .padding(.bottom, Dimen.margin.heavy)
                }
            } else {
                Button(action: {
                    self.appSceneObserver.event = .initate
                    
                }) {
                    ZStack(alignment: .top){
                        Text(String.pageText.introComplete)
                            .modifier(BoldTextStyle(
                                size: Font.size.regular,
                                color: Color.app.grey500
                            ))
                            .modifier(MatchParent())
                            .background(Color.app.white)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.lightExtra))
                            .modifier(Shadow())
                        Image(Asset.shape.point)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20,
                                   height: 20)
                            .padding(.top,-20 )
                            .padding(.leading,-20 )
                    }
                    .frame(width: 226, height: 57)
                    .padding(.bottom, Dimen.margin.heavy)
                }
            }
        }
        .onReceive( self.viewModel.$index ){ idx in
            self.index = idx
        }
        .onAppear{
           // self.setBar(idx:self.index)
        }
        
    }//body
    
}


#if DEBUG
struct PageIntro_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageIntro().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(Repository())
                .frame(width: 325, height: 640, alignment: .center)
        }
    }
}
#endif

