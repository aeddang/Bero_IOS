//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct GraphHorizontal: PageView {
    var progress: Float // or some value binded
    var progressColor:Gradient = Gradient(colors: [Color.brand.primary, Color.brand.primary])
    var bgColor:Color = Color.app.white
    var stroke:CGFloat =  Dimen.bar.regular
    var cornerRadius:CGFloat = Dimen.radius.micro
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Spacer()
                    .modifier(MatchParent())
                    .background(self.bgColor)
                ZStack{
                    LinearGradient(
                        gradient:self.progressColor,
                        startPoint: .leading, endPoint: .trailing)
                        .modifier(MatchParent())
                }
                .modifier(MatchVertical(width: geometry.size.width * CGFloat(progress) ))
                .animation(.easeIn)
            }
            .modifier(MatchHorizontal(height: self.stroke))
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
        }
    }
}
#if DEBUG
struct GraphHorizontal_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GraphHorizontal(
                progress:  0.8
            )
            .frame(width: 156)
        }
    }
}
#endif
