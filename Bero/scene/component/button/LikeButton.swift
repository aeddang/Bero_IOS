//
//  LikeButton.swift
//  Bero
//
//  Created by JeongCheol Kim on 2023/06/29.
//
import Foundation
import SwiftUI
import FirebaseAnalytics
struct LikeButton: View, SelecterbleProtocol, PageProtocol {
    var isLike:Bool = false
    var sizeType:SortButton.SizeType = .big
    var likeCount:Double? = nil
    var action: () -> Void
    var body: some View {
        HStack(alignment: .center, spacing: 0){
            SortButton(
                type: .stroke,
                sizeType: self.sizeType,
                icon: self.isLike ? Asset.icon.favorite_on : Asset.icon.favorite_off,
                text: "",
                color: self.isLike ? Color.brand.primary : Color.app.grey400,
                isSort: false
            ){
                self.action()
            }
            .fixedSize()
            if let likeCount = self.likeCount {
                ZStack{
                    Text(likeCount.toThousandUnit() + " " + String.app.likes)
                        .modifier(RegularTextStyle(size: Font.size.thin,color: Color.app.grey400))
                        .padding(.vertical,  Dimen.margin.tinyExtra)
                        .padding(.horizontal,  Dimen.margin.light)
                        .multilineTextAlignment(.center)
                }
                .background(Color.app.whiteDeepLight)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
                .padding(.leading, Dimen.margin.tinyExtra )
                .fixedSize()
                .onTapGesture {
                    self.action()
                }
            }
            
        }
    }
}




