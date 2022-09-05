//
//  TitleTab.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/20.
//

//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI

struct ArcGraphData{
    var value:Float = 0
    var max:Float = 7
    var start:String = "Goal"
    var end:String = String.pageText.reportWalkDayUnit

}


struct ArcGraph: PageComponent{
    var size:CGFloat = 156
    var textSize:CGFloat = 100
    var data:ArcGraphData = ArcGraphData()
    var innerCircleColor:Color = Color.app.white
    @State var progress:Float = 0
    var body: some View {
        VStack(spacing: 0){
            GraphArc(progress: self.data.value/self.data.max,
                     innerCircleColor:self.innerCircleColor)
                .frame(width: self.size, height: self.size)
                .frame(height: self.size/2, alignment: .top)
                .clipped()
            HStack(spacing: 0){
                Text(self.data.start)
                    .modifier(BoldTextStyle(
                        size: Font.size.tiny,
                        color: Color.app.grey400
                    ))
                    .frame(width: self.textSize)
                Spacer()
                    .frame(width: self.size
                           - self.textSize
                           - Dimen.stroke.heavy)
                HStack(spacing: 0){
                    Text(Int(self.data.value).description)
                        .modifier(MediumTextStyle(
                            size: Font.size.thin,
                            color: Color.brand.primary
                        ))
                    
                    Text("/" + Int(self.data.max).description + self.data.end)
                        .modifier(MediumTextStyle(
                            size: Font.size.thin,
                            color: Color.app.black
                        ))
                }
                .frame(width: self.textSize)
            }
            .padding(.top, Dimen.margin.micro)
        }
    }
}

#if DEBUG
struct ArcGraph_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ArcGraph()
                .environmentObject(PagePresenter()).frame(width:320,height:500)
                
        }
    }
}
#endif

