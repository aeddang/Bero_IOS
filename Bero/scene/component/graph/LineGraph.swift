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

struct LineGraphData{
    var values:[Float] = [0.2, 0.0, 1.0, 0.4]
    var lines:[String] = ["1/1", "1/2", "1/3", "1/4"]
    var raws:[String] = ["0","10", "20", "30", "40", ""]
    var primaryRaws:[String] = ["20", "30"]
    var rawsUnit:String = "(minutes)"
}



struct LineGraph: PageComponent{
    var size:CGFloat = 156
    var textSize:CGFloat = 100
    var selectIdx:Int = 1
    var data:LineGraphData = LineGraphData()
    var rawsWidth:CGFloat = 30
    var primaryColor:Color = Color.brand.primary
    var body: some View {
        VStack(spacing: 0){
            ZStack(alignment: .topLeading){
                HStack(spacing: 0){
                    VStack(spacing: 0){
                        ForEach(self.data.raws.reversed(), id: \.self){ raw in
                            Text(raw)
                                .modifier(RegularTextStyle(
                                    size: Font.size.tiny,
                                    color: Color.app.grey300
                                ))
                                .padding(.top, Dimen.margin.thin)
                                .frame(width: self.rawsWidth, height:Dimen.bar.medium)
                        }
                    }
                    .modifier(MatchVertical(width: self.rawsWidth))
                    VStack(spacing: 0){
                        ForEach(zip(0..<self.data.raws.count, self.data.raws.reversed()).map{ idx , raw in
                            RawData(
                                id:UUID().uuidString,
                                idx: idx,
                                data: raw
                            )
                        }){ raw in
                            if raw.idx == 0 {
                                HStack(alignment: .bottom, spacing: 0){
                                    LineHorizontalDotted()
                                        .stroke(style: StrokeStyle(lineWidth: Dimen.stroke.light, dash: [3]))
                                        .foregroundColor(Color.app.grey300)
                                        .padding(.top, Dimen.bar.medium-Dimen.stroke.light)
                                }
                                .modifier(MatchHorizontal(height: Dimen.bar.medium))
                                .background( self.data.primaryRaws.firstIndex(of:raw.data) == nil ? Color.transparent.clear : self.primaryColor.opacity(0.1)
                                )
                            } else {
                                HStack(alignment: .bottom, spacing: 0){
                                    Spacer().modifier(LineHorizontal(height: Dimen.stroke.light, color: Color.app.grey300))
                                        .padding(.top, Dimen.bar.medium)
                                }
                                .modifier(MatchHorizontal(height: Dimen.bar.medium))
                                .background( self.data.primaryRaws.firstIndex(of:raw.data) == nil ? Color.transparent.clear : self.primaryColor.opacity(0.1)
                                )
                            }
                        }
                    }
                    .modifier(MatchParent())
                }

                GraphLine(
                    selectIdx: self.selectIdx,
                    selectedColor: self.primaryColor,
                    points:  self.data.values)
                    .padding(.horizontal, self.rawsWidth)
                    .modifier(MatchHorizontal(height: Dimen.bar.medium*CGFloat(self.data.raws.count-1) ))
                    .padding(.leading, self.rawsWidth)
                    .padding(.top, Dimen.bar.medium)
                
                Text(self.data.rawsUnit)
                    .modifier(RegularTextStyle(
                        size: Font.size.tiny,
                        color: Color.app.grey300
                    ))
            }
            if self.data.lines.count <= 10 {
                HStack(alignment: .bottom, spacing: 0){
                    ForEach(zip(0..<self.data.lines.count, self.data.lines).map{ idx , line in
                        LineData(
                            id:UUID().uuidString,
                            idx: idx,
                            data: line
                        )
                    }){ line in
                        Text(line.data)
                            .modifier(RegularTextStyle(
                                size: Font.size.tiny,
                                color: line.idx == self.selectIdx ? self.primaryColor : Color.app.grey300
                            ))
                            .modifier(MatchHorizontal(height: Dimen.bar.medium))
                    }
                }
                .padding(.leading, self.rawsWidth)
            }
            
        }
    }
    
    struct LineData:Identifiable{
        let id:String
        let idx:Int
        let data:String
    }
    
    struct RawData:Identifiable{
        let id:String
        let idx:Int
        let data:String
    }
}

#if DEBUG
struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            LineGraph()
                .environmentObject(PagePresenter()).frame(width:320)
                
        }
    }
}
#endif

