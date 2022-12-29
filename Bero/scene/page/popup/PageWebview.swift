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
                axis:.vertical
            ) {
                ZStack(alignment: .topTrailing){
                    CustomWebView(
                        viewModel: self.webViewModel
                    )
                    .modifier(MatchParent())
                    ImageButton(
                        isSelected: false,
                        defaultImage:Asset.icon.close,
                        padding: Dimen.margin.tiny
                    ){_ in
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                    .padding(.all, Dimen.margin.regular)
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
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    @State var link:String = ""
    
}


