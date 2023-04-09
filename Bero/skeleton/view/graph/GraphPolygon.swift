//
//  GraphLine.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/23.
//

//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct GraphPolygon: PageView {
    var selectIdx:[Int] = []
    var points:[CGPoint]? = nil // percent set
    
    var selectedColor:Color = Color.brand.primary
    var pointColor:Color = Color.app.green
    var lineColor:Color = Color.brand.primary
    var stroke:CGFloat = Dimen.stroke.heavyUltra
    var usePoint:Bool = true
    var action: ((Int) -> Void)? = nil
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                if self.points?.isEmpty == false {
                    let positions = self.getPositions(geometry)
                    Line(
                        points: positions
                    )
                    .stroke(self.lineColor, style: .init(lineWidth: self.stroke, lineCap: .round, lineJoin: .round))
                    .foregroundColor(self.lineColor)
                    if self.usePoint {
                        ForEach(zip(0..<positions.count, positions).map{ idx , pos in
                            PointData(
                                id:UUID().uuidString,
                                idx: idx,
                                pos: pos
                            ).setup(
                                selectIdx: self.selectIdx,
                                selectedColor: self.selectedColor,
                                pointColor: self.pointColor,
                                lineColor: self.lineColor,
                                count: positions.count)
                        }.filter{$0.isSelect})
                        { p in
                            ZStack{
                                Circle()
                                    .stroke(p.color,lineWidth: p.isStroke
                                            ? p.isShadow ? self.stroke : 1
                                            : 0)
                                    .background(Circle().fill(p.bgColor))
                                    .frame(
                                        width: p.isShadow ? Dimen.icon.tiny : Dimen.icon.microUltra,
                                        height: p.isShadow ? Dimen.icon.tiny : Dimen.icon.microUltra
                                    )
                                    .modifier(Shadow(opacity: p.isShadow ? 0.12 : 0))
                                if let icon = p.icon {
                                    Image(icon)
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Dimen.icon.light, height: Dimen.icon.light)
                                        .offset(x:7, y:-10)
                                }
                            }
                            .frame(
                                width: p.isShadow ? Dimen.icon.tiny : Dimen.icon.microUltra,
                                height: p.isShadow ? Dimen.icon.tiny : Dimen.icon.microUltra
                            )
                            .position(x: p.pos.x, y: p.pos.y)
                            .onTapGesture{
                                if !p.isSelect {return}
                                self.action?(p.idx)
                            }
                            
                        }
                    }
                }
            }
            .modifier(MatchParent())
        }
    }
    
    private func getPositions(_ geometry:GeometryProxy)->[CGPoint]{
        let positions:[CGPoint] = zip(0..<self.points!.count, self.points!).map{idx, p in
            
            return CGPoint(
                x: geometry.size.width * p.x ,
                y: geometry.size.height * p.y )
        }
        return positions
    }
    
    class PointData:Identifiable{
        let id:String
        var icon:String? = nil
        let idx:Int
        let pos:CGPoint
        var color:Color = .black
        var bgColor:Color = .white
        var isSelect:Bool = false
        var isStroke:Bool = false
        var isShadow:Bool = false
        init(id:String,idx:Int,pos:CGPoint){
            self.id = id
            self.idx = idx
            self.pos = pos
        }
        func setup(
            selectIdx:[Int],
            selectedColor:Color,
            pointColor:Color,
            lineColor:Color,
            count:Int
        )->PointData{
            let idx = self.idx
           
            if idx == 0 {
                self.bgColor = selectedColor
                self.color = .white
                self.isSelect = true
                self.isStroke = true
                self.isShadow = true
            } else if idx == count-1  {
                self.color = selectedColor
                self.isSelect = true
                self.isStroke = true
                self.isShadow = true
                self.icon = Asset.icon.route_flag
            } else {
                let isSelect:Bool = selectIdx.first(where: {$0 == idx}) != nil
                self.bgColor = isSelect ? pointColor : lineColor
                self.color = .white
                self.isSelect = isSelect
                self.isStroke = isSelect
                self.isShadow = false
                
            }
            return self
        }
    }
}


#if DEBUG
struct GraphPolygon_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GraphPolygon(
                selectIdx: [2,4],
                points:  [
                    .init(x:0.2, y:0.2),
                    .init(x:0.5, y:0.5),
                    .init(x:0.5, y:0.9),
                    .init(x:0.2, y:0.5),
                    .init(x:0.2, y:0.2)
                ]
            )
            .frame(width: 200, height:150)
        }
    }
}
#endif




