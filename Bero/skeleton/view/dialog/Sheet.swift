//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


extension View {
    func sheet(isShowing: Binding<Bool>,
               title:String? = nil,
               description:String? = nil,
               image:String? = nil,
               buttons:[SheetBtnData]? = nil,
               cancel: @escaping () -> Void,
               action: @escaping (_ idx:Int) -> Void
    ) -> some View {
        var alertBtns:[SheetBtnData] = buttons ?? []
        if buttons == nil {
            let btns = [
                String.app.cancel,
                String.app.confirm
            ]
            let range = 0 ..< btns.count
            alertBtns = zip(range,btns).map {index, text in SheetBtnData(title: text, index: index)}
        }
        return Sheet(
            isShowing: isShowing,
            title:title,
            description:description,
            image:image,
            buttons:alertBtns,
            presenting: { self },
            cancel: cancel,
            action:action
        )
    }
}
struct SheetBtnData:Identifiable, Equatable{
    let id = UUID.init()
    let title:String
    var img:String? = nil
    let index:Int
}


struct Sheet<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    var title:String? = nil
    var description:String? = nil
    var image:String? = nil
    var buttons: [SheetBtnData] = []
    let presenting: () -> Presenting
    var cancel:() -> Void
    let action: (_ idx:Int) -> Void
    @State var safeAreaBottom:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Button(action: {
                    withAnimation{
                        self.isShowing = false
                    }
                    self.cancel()
                }) {
                   Spacer().modifier(MatchParent())
                       .background(Color.transparent.black70)
                       .opacity(self.pageOpacity)
                }
                VStack(alignment: .leading, spacing: 0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    VStack(alignment: .leading, spacing: Dimen.margin.regularExtra){
                        if let title = self.title {
                            Text(title)
                                .modifier(BoldTextStyle(
                                    size: Font.size.bold,
                                    color: Color.app.black
                                ))
                        }
                        
                        if let description = self.description {
                            Text(description)
                                .modifier(RegularTextStyle(
                                    size: Font.size.light,
                                    color: Color.app.grey400
                                ))
                        }
                        
                    }
                    if let image = self.image {
                        Image(image)
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .modifier(MatchHorizontal(height: 146))
                            .padding(.top, Dimen.margin.medium)
                    }
                    HStack(spacing:Dimen.margin.tiny){
                        ForEach(self.buttons) { btn in
                            FillButton(
                                type: .fill,
                                icon: btn.img,
                                text: btn.title,
                                index: btn.index,
                                color: Color.app.grey50,
                                textColor: btn.index%2 == 1 ? nil : Color.app.grey400,
                                gradient: btn.index%2 == 1 ? Color.app.orangeGradient : nil
                                
                            ){idx in
                                self.action(idx)
                                withAnimation{
                                    self.isShowing = false
                                }
                            }
                        }
                    }
                    .padding(.top, Dimen.margin.regular)
                }
                .padding(.bottom, self.safeAreaBottom)
                .modifier(BottomFunctionTab())
                .padding(.bottom, self.isShowing ? 0 : -300)
                .offset(self.dragAmount)
            }
            .opacity(self.isShowing ? 1 : 0)
            .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
                withAnimation{
                    self.safeAreaBottom = pos
                }
            }
            .highPriorityGesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .global)
                    .onChanged({ value in self.drag(value: value, screenHeight: geometry.size.height)})
                    .onEnded({ value in self.dragCompleted(value: value, screenHeight: geometry.size.height)})
            )
            .gesture(
                PageDragingModel.cancelGesture
                    .onChanged({_ in self.dragCancel()})
                    .onEnded({_ in self.dragCancel()})
            )
        }
    }
    
    
    
    @State var pageOpacity:Double = 1
    @State var dragAmount = CGSize.zero
    private func drag(value:DragGesture.Value, screenHeight:CGFloat){
        let offset = value.translation.height
        
        withAnimation(.easeOut(duration: PageContentBody.pageMoveDuration)){
            self.dragAmount = CGSize(width: 0, height: max(0,offset))
            self.pageOpacity = (screenHeight-offset)/screenHeight
        }
    }
    private func dragCompleted(value:DragGesture.Value, screenHeight:CGFloat){
        if value.predictedEndTranslation.height > screenHeight/3 {
            withAnimation(.easeOut(duration: PageContentBody.pageMoveDuration)){
                self.isShowing = false
            }
            self.cancel()
            self.dragCancel()
        } else {
            self.dragCancel()
        }
    }
    private func dragCancel(){
        withAnimation(.easeOut(duration: 0.3)){
            self.dragAmount = CGSize.zero
            self.pageOpacity = 1
        }
    }
    
}
#if DEBUG
struct Sheet_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .sheet(
            isShowing: .constant(true),
            title: "TITLE",
            description: "desc",
            image: Asset.image.addDog,
            cancel: {
                
            },
            action: { idx in
                
            }
        )
        .environmentObject(PageSceneObserver())
    }
}
#endif

