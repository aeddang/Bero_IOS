//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct PageWebview: PageView {
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
                        title: self.title,
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
                .onReceive(self.webViewModel.$status){ status in
                    
                    switch status {
                    case .complete :
                        self.pagePresenter.isLoading = false
                    default : break
                    }
                    
                }
            }//draging
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.webViewModel.request = .link(self.link)
                }
            }
            .onAppear{
                self.pagePresenter.isLoading = true
                guard let obj = self.pageObject  else { return }
                if let link = obj.getParamValue(key: .link) as? String{
                    self.link = link
                }
                if let title = obj.getParamValue(key: .title) as? String{
                    self.title = title
                }
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    @State var title:String? = nil
    @State var link:String = ""
    
}


