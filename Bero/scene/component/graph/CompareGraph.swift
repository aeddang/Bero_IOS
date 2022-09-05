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

struct CompareGraphData:Identifiable{
    let id = UUID().uuidString
    var value:Float = 0
    var max:Float = 7
    var color:Color = Color.brand.primary
    var title:String = "You"
    var end:String = String.pageText.reportWalkDayUnit
}


struct CompareGraph: PageComponent{
    var textSize:CGFloat = 52
    var datas:[CompareGraphData] = []
   
    var body: some View {
        VStack(spacing: Dimen.margin.regular){
            ForEach(self.datas){ data in
                HStack(spacing: 0){
                    VStack(alignment:.leading, spacing: 0){
                        Spacer().frame(width: self.textSize, height:0)
                        Text(data.title)
                            .multilineTextAlignment(.leading)
                            .modifier(BoldTextStyle(
                                size: Font.size.tiny,
                                color: data.color
                            ))
                           
                    }
                    ZStack(alignment: .trailing){
                        GraphHorizontal(
                            progress:  data.value/data.max,
                            progressColor: Gradient(colors: [data.color.opacity(0.7), data.color]),
                            bgColor: Color.app.grey50
                        )
                        .modifier(MatchHorizontal(height: Dimen.bar.regular))
                        HStack(spacing: 0){
                            Text( Double(data.value).toTruncateDecimal(n:2))
                                .modifier(MediumTextStyle(
                                    size: Font.size.micro,
                                    color: Color.app.grey500
                                ))
                            
                            Text("/" + Double(data.max).toTruncateDecimal(n:0) + data.end)
                                .modifier(MediumTextStyle(
                                    size: Font.size.micro,
                                    color: Color.app.grey300
                                ))
                        }
                    }
                }
            }
        }

    }
}

#if DEBUG
struct CompareGraph_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CompareGraph(datas:[CompareGraphData(title:"test"),CompareGraphData()])
                .environmentObject(PagePresenter()).frame(width:320,height:500)
                
        }
    }
}
#endif

