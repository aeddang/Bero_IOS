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
    var selectedColor:Color = Color.brand.primary
    var startColor:Color? = Color.app.black
    var endColor:Color? = Color.app.green
    var points:[CGPoint]? = nil // percent set
    var lineColor:Color = Color.app.grey400
    var stroke:CGFloat = Dimen.stroke.heavy
    var usePoint:Bool = true
    var action: ((Int) -> Void)? = nil
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                if self.points?.isEmpty == false, let positions = self.getPositions(geometry) {
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
                                startColor: self.startColor,
                                endColor: self.endColor,
                                lineColor: self.lineColor,
                                count: positions.count)
                        }){ p in
                            
                            Circle()
                                .stroke(p.color,lineWidth: self.stroke)
                                .background(Circle().fill(Color.app.white))
                                .frame(
                                    width: p.isSelect ? Dimen.icon.microUltra : Dimen.icon.micro,
                                    height: p.isSelect ? Dimen.icon.microUltra : Dimen.icon.micro,
                                    alignment: .topLeading)
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
        let idx:Int
        let pos:CGPoint
        var color:Color = .black
        var isSelect:Bool = false
        
        init(id:String,idx:Int,pos:CGPoint){
            self.id = id
            self.idx = idx
            self.pos = pos
        }
        func setup(
            selectIdx:[Int],
            selectedColor:Color,
            startColor:Color?,
            endColor:Color?,
            lineColor:Color,
            count:Int
        )->PointData{
            let idx = self.idx
            let isSelect:Bool = selectIdx.first(where: {$0 == idx}) != nil
            var color:Color = isSelect ? selectedColor : lineColor
            if idx == 0, let c = startColor {
                color = c
            }
            if idx == count-1 , let c = endColor {
                color = c
            }
            self.color = color
            self.isSelect = isSelect
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




