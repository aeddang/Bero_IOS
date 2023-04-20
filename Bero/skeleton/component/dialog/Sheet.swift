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
               icon:String? = nil,
               title:String? = nil,
               description:String? = nil,
               image:String? = nil,
               point:Int? = nil,
               exp:Double? = nil,
               buttons:[SheetBtnData]? = nil,
               buttonColor:Color? = nil,
               isLock:Bool = false,
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
            icon: icon,
            title:title,
            description:description,
            image:image,
            point: point,
            exp: exp,
            buttons:alertBtns,
            buttonColor: buttonColor,
            isLock: isLock,
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
    var icon:String? = nil
    var title:String? = nil
    var description:String? = nil
    var image:String? = nil
    var point:Int? = nil
    var exp:Double? = nil
    var buttons: [SheetBtnData] = []
    var buttonColor:Color? = nil
    var isLock:Bool = false
    let presenting: () -> Presenting
    var cancel:() -> Void
    let action: (_ idx:Int) -> Void
    @State var safeAreaBottom:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if self.isLock {
                    Spacer().modifier(MatchParent())
                        
                } else {
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
                }
                VStack(alignment: .leading, spacing: 0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    VStack(alignment: .leading, spacing: Dimen.margin.light){
                        if let icon = self.icon {
                            Image(icon)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .foregroundColor(Color.brand.primary)
                                .frame(width: Dimen.icon.heavyUltra, height: Dimen.icon.heavyUltra)
                        }
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
                    if self.point != nil || self.exp != nil {
                        ZStack(alignment: .bottom){
                            Spacer().modifier(MatchHorizontal(height: 0))
                            LottieView(lottieFile: "welcome_gift_box", mode: .playOnce)
                                .frame(width: 230, height: 275)
                            HStack(spacing:Dimen.margin.thin){
                                if let exp = self.exp {
                                    RewardInfo(
                                        type: .exp,
                                        sizeType: .big,
                                        value: exp.toInt(),
                                        isActive: true
                                    )
                                }
                                if let point = self.point {
                                    RewardInfo(
                                        type: .point,
                                        sizeType: .big,
                                        value: point,
                                        isActive: true
                                    )
                                }
                            }
                        }
                    }
                    HStack(spacing:Dimen.margin.tiny){
                        ForEach(self.buttons) { btn in
                            FillButton(
                                type: .fill,
                                icon: btn.img,
                                text: btn.title,
                                index: btn.index,
                                color: btn.index%2 == 1 ? (self.buttonColor ?? Color.app.white) : Color.app.grey50,
                                textColor: btn.index%2 == 1 ? nil : Color.app.grey400,
                                gradient: btn.index%2 == 1
                                    ? (self.buttonColor == nil ? Color.app.orangeGradient : nil)
                                    : nil
                                
                            ){idx in
                                self.action(idx)
                                withAnimation{
                                    self.isShowing = false
                                }
                            }
                        }
                    }
                    .padding(.top, Dimen.margin.medium)
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
        if self.isLock {return}
        let offset = value.translation.height
        
        withAnimation(.easeOut(duration: PageContentBody.pageMoveDuration)){
            self.dragAmount = CGSize(width: 0, height: max(0,offset))
            self.pageOpacity = (screenHeight-offset)/screenHeight
        }
    }
    private func dragCompleted(value:DragGesture.Value, screenHeight:CGFloat){
        if self.isLock {return}
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
            //icon: Asset.icon.walk,
            title: String.alert.welcome,
            description: String.alert.welcomeText,
            //image: Asset.image.addDog,
            point: 99,
            //exp: 99,
            buttons: [.init(title: String.app.confirm, index: 1)],
            cancel: {},
            action: { idx in
                
            }
        )
        .environmentObject(PageSceneObserver())
    }
}
#endif

