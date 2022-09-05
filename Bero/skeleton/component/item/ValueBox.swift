//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct ValueData:Identifiable{
    let id:String = UUID().uuidString
    let idx:Int
    let type:ValueBox.ValueType
    
}


struct ValueBox: PageComponent{
    enum ValueType{
        case progress(String, percent:Double), value(ValueInfo.ValueType, value:Double)
    }
    var datas:[ValueData] = []
    var action: ((ValueType) -> Void)? = nil
    var body: some View {
        HStack(spacing:Dimen.margin.light){
            ForEach(self.datas) { data in
                switch data.type {
                case .progress(let title, let percent) :
                    Button(action: {
                        self.action?(data.type)
                    }) {
                        ProgressInfo(
                            title: title,
                            progress: percent,
                            progressMax: 100)
                        .frame(height: 48)
                    }
                case .value(let type, let value) :
                    Button(action: {
                        self.action?(data.type)
                    }) {
                        ValueInfo(
                            type: type,
                            value: value
                        )
                        .modifier(MatchParent())
                    }
                }
                if data.idx < self.datas.count-1 {
                    Spacer().modifier(LineVertical(
                        width: Dimen.line.light,
                        margin: Dimen.margin.micro,
                        color: Color.app.grey100))
                }
            }
        }
        .padding(.horizontal, Dimen.margin.light)
        .modifier(MatchHorizontal(height: 84))
        .background(Color.app.white )
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
        .overlay(
            RoundedRectangle(cornerRadius: Dimen.radius.thin)
                .strokeBorder(
                    Color.app.grey100,
                    lineWidth: Dimen.stroke.light
                )
        )
        .modifier(ShadowLight())
    }
}


#if DEBUG
struct ValueBox_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
           ValueBox(datas: [
                .init(idx: 0, type: .progress("LV", percent: 52)),
                .init(idx: 1, type: .value(.point, value: 100))
                //.init(idx: 2, type: .value(.coin, value: 10.3))
            
            ]){ type in
                 
            }
           
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
