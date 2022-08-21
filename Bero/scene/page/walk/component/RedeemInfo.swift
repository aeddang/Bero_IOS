//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine



struct RedeemInfo: PageComponent {
    var type:MissionType
    var title:String? = nil
    var text:String? = nil
    var point:Int = 0
    var action: (() -> Void)? = nil
    var close: (() -> Void)? = nil
    var body: some View {
        ZStack(alignment: .topTrailing){
            VStack(spacing: 0){
                Image(Asset.image.present)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 123, height: 123)
                if let title = self.title {
                    Text(title)
                        .modifier(BoldTextStyle(
                            size: Font.size.medium,
                            color: Color.app.white
                        ))
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let text = self.text {
                    VStack{
                        Text(text)
                            .modifier(BoldTextStyle(
                                size: Font.size.thin,
                                color: Color.app.white
                            ))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, Dimen.margin.light)
                            .padding(.vertical, Dimen.margin.regular)
                    }
                    .background(Color.brand.primary)
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                    .padding(.horizontal, Dimen.margin.thin)
                    .padding(.top, Dimen.margin.regular)
                }
                
                HStack(alignment: .center, spacing: Dimen.margin.tiny){
                    Text(self.type.completeButton)
                        .modifier(RegularTextStyle(
                            size: Font.size.light,
                            color: Color.app.grey500
                        ))
                    Image(Asset.icon.point)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    Text(self.point.formatted(style: .decimal))
                        .modifier(MediumTextStyle(
                            size: Font.size.light,
                            color: Color.brand.primary
                        ))
                        
                }
                .padding(.horizontal, Dimen.margin.light)
                .padding(.vertical, Dimen.margin.light)
                .background(Color.app.white)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                .padding(.horizontal, Dimen.margin.light)
                .padding(.vertical, Dimen.margin.regular)
                .onTapGesture {
                    self.action?()
                }
            }
            .frame(width: 320)
            .background(Color.brand.primary)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
            .padding(.all, Dimen.margin.thin)
            
            if let close = self.close {
                Button(action: {
                    close()
                }) {
                    Image(Asset.icon.close)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regular,
                               height: Dimen.icon.regular)
                }
            }
        }
    }//body
   
}


#if DEBUG
struct RedeemInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            RedeemInfo(type: .walk)
            .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

