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
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    @State var pages: [PageViewProtocol] = []
    let titles: [String] =
    [
        String.pageText.introText1_1,
        String.pageText.introText2_1,
        String.pageText.introText3_1
    ]
    let texts: [String] =
    [
        String.pageText.introText1_2,
        String.pageText.introText2_2,
        String.pageText.introText3_2
    ]
    @State var index: Int = 0
    @State var leading:CGFloat = 0
    @State var trailing:CGFloat = 0
    @State var sceneOrientation: SceneOrientation = .portrait
    @State var isComplete:Bool = false
    var body: some View {
        ZStack(alignment: .bottom){
            CPImageViewPager(
                viewModel : self.viewModel,
                pages: self.pages,
                useButton: true,
                bottomMargin: 90
            )
            /*
            Text(self.titles[self.index])
                .modifier(BoldTextStyle(size: Font.size.bold, color: Color.app.black))
                .padding(.top, Dimen.margin.medium)
                .fixedSize()
                .padding(.horizontal, Dimen.margin.regular)
            Text(self.texts[self.index])
                .modifier(MediumTextStyle(size: Font.size.light, color: Color.app.black))
                .padding(.top, Dimen.margin.thin)
                .fixedSize()
                .padding(.horizontal, Dimen.margin.regular)
            */
            FillButton(
                type: .fill,
                text: self.isComplete
                ? String.pageText.introComplete
                : String.button.next,
                color: self.isComplete ? Color.app.white : Color.app.black,
                gradient:  self.isComplete ? Color.app.orangeGradient : nil
            ){_ in
                if self.isComplete {
                    self.appSceneObserver.event = .initate
                } else {
                    self.viewModel.request = .move(self.index + 1)
                }
            }
            .padding(.top, Dimen.margin.heavyExtra)
            .padding(.bottom, Dimen.margin.medium)
            .padding(.horizontal, Dimen.margin.regular)
        }
        .onReceive( self.viewModel.$index ){ idx in
            withAnimation{
                self.index = idx
                self.isComplete = idx >= (self.pages.count - 1)
            }
        }
        .onAppear{
            self.pages =
            [
                IntroLottie(
                    viewModel: self.viewModel,
                    lottie: LottieView(lottieFile: Asset.intro.onboarding_ani_0, autoPlay: false),
                    index: 0
                ),
                IntroLottie(
                    viewModel: self.viewModel,
                    lottie: LottieView(lottieFile: Asset.intro.onboarding_ani_1, autoPlay: false),
                    index: 1
                ),
                IntroLottie(
                    viewModel: self.viewModel,
                    lottie: LottieView(lottieFile: Asset.intro.onboarding_ani_2, autoPlay: false),
                    index: 2
                )
            ]
           // self.setBar(idx:self.index)
        }
    }//body
}

struct IntroLottie: PageComponent, Identifiable {
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    @EnvironmentObject var sceneObserver:PageSceneObserver
    let id = UUID().uuidString
    let lottie:LottieView
    let index:Int
    
    var body: some View {
        ZStack(){
            Spacer().modifier(MatchParent())
            self.lottie
            .modifier(MatchParent())
        }
        .modifier(MatchParent())
        .background(Color.app.white)
        .onReceive( self.viewModel.$index ){ idx in
            if self.index == idx {
                self.lottie.play()
            }
        }
    }
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

