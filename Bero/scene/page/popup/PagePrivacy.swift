//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct PagePrivacy: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var webViewModel = WebViewModel()

    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    TitleTab(
                        useBack: true, action: { type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            default : break
                            }
                        })
                    CustomWebView(
                        viewModel: self.webViewModel
                    )
                    .modifier(MatchParent())
                        
                }
                .modifier(PageVertical())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.webViewModel.request = .link("https://bero.dog/privacystatement")
                }
            }
            .onAppear{
               
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
    
}

#if DEBUG
struct PagePrivacy_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePrivacy().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())

                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
