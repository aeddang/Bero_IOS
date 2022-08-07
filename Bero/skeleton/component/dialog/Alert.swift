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
    func alert(isShowing: Binding<Bool>,
               title: String? = nil,
               image: UIImage? = nil,
               text: String? = nil,
               subText: String? = nil,
               tipText: String? = nil,
               referenceText: String? = nil,
               imgButtons:[AlertBtnData]? = nil,
               buttons:[AlertBtnData]? = nil,
               action: @escaping (_ idx:Int) -> Void ) -> some View {
        
        var alertBtns:[AlertBtnData] = buttons ?? []
        if buttons == nil {
            let btns = [
                String.app.cancel,
                String.app.confirm
            ]
            let range = 0 ..< btns.count
            alertBtns = zip(range,btns).map {index, text in AlertBtnData(title: text, index: index)}
        }
        
        return Alert(
            isShowing: isShowing,
            presenting: { self },
            title:title,
            image:image,
            text:text,
            subText:subText,
            tipText:tipText,
            referenceText: referenceText,
            imgButtons : imgButtons,
            buttons: alertBtns,
            action:action)
    }
    
}
struct AlertBtnData:Identifiable, Equatable{
    let id = UUID.init()
    let title:String
    var img:String? = nil
    let index:Int
}


struct Alert<Presenting>: View where Presenting: View {
    let maxTextCount:Int = 200
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    var title: String?
    var image: UIImage?
    var text: String?
    var subText: String?
    var tipText: String?
    var referenceText: String?
    var imgButtons: [AlertBtnData]?
    var buttons: [AlertBtnData]
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack{
                VStack (alignment: .center, spacing:0){
                    if (self.text?.count ?? 0) > self.maxTextCount {
                        ScrollView{
                            AlertBody(title: self.title, image: self.image, text: self.text, subText: self.subText, tipText: self.tipText, referenceText: self.referenceText)
                        }
                        .padding(.bottom, Dimen.margin.medium)
                    } else {
                        AlertBody(title: self.title, image: self.image, text: self.text, subText: self.subText, tipText: self.tipText, referenceText: self.referenceText)
                            .padding(.bottom, Dimen.margin.medium)
                            
                    }
                    if self.imgButtons != nil {
                        HStack(spacing:Dimen.margin.regular){
                            ForEach(self.imgButtons!) { btn in
                                ImageButton(
                                    isSelected: true,
                                    index: btn.index,
                                    defaultImage: btn.img ?? Asset.icon.tag,
                                    size: CGSize(width: Dimen.icon.heavy, height: Dimen.icon.heavy), text: btn.title
                                    
                                ){idx in
                                    self.action(idx)
                                    withAnimation{
                                        self.isShowing = false
                                    }
                                }
                                .clipShape(Circle())
                            }
                        }
                        .padding(.bottom, Dimen.margin.medium)
                    }
                    HStack(spacing:Dimen.margin.tiny){
                        ForEach(self.buttons) { btn in
                            FillButton(
                                type: .fill,
                                icon: btn.img,
                                text: btn.title,
                                index: btn.index,
                                color: btn.index%2 == 1 ? Color.app.black : Color.app.grey200
                                
                            ){idx in
                                self.action(idx)
                                withAnimation{
                                    self.isShowing = false
                                }
                            } 
                        }
                    }
                }
                .padding(.all, Dimen.margin.regular)
                .background(Color.app.white)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.lightExtra))
            }
            .frame(
                minWidth: 0,
                idealWidth:  320,
                maxWidth:   320,
                minHeight: 0,
                maxHeight: (self.text?.count ?? 0) > self.maxTextCount
                    ?  320
                    : .infinity
            )
            .modifier(Shadow())
            .padding(.all, Dimen.margin.regular)
            
        }
        .modifier(MatchParent())
        .background(Color.transparent.black70)
        .opacity(self.isShowing ? 1 : 0)
        
    }
}

struct AlertBody: PageComponent{
    var title: String?
    var image: UIImage?
    var text: String?
    var subText: String?
    var tipText: String?
    var referenceText: String?
    var body: some View {
        VStack (alignment: .center, spacing:0){
            if self.title != nil{
                Text(self.title!)
                    .modifier(BoldTextStyle(size: Font.size.regular))
                    .fixedSize(horizontal: false, vertical: true)
                    
            }
            if self.image != nil{
                Image(uiImage: self.image!)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                    .padding(.top, Dimen.margin.medium)
                    
            }
            if self.text != nil{
                Text(self.text!)
                    .multilineTextAlignment(.center)
                    .modifier(MediumTextStyle(size: Font.size.light))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Dimen.margin.medium)
            }
            if self.subText != nil{
                Text(self.subText!)
                    .multilineTextAlignment(.center)
                    .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.grey50))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Dimen.margin.tiny)
            }
            if self.tipText != nil{
                Text(self.tipText!)
                    .multilineTextAlignment(.center)
                    .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.brand.primary))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Dimen.margin.regular)
            }
            if self.referenceText != nil{
                Text(self.referenceText!)
                    .multilineTextAlignment(.center)
                    .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.app.grey50))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Dimen.margin.tiny)
            }
        }
    }
}

#if DEBUG
struct Alert_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .alert(
            isShowing: .constant(true),
            title:"TEST",
            text: "text",
            subText: "subtext",
            buttons: nil
        ){ _ in
        
        }

    }
}
#endif
