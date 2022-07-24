//
//  CustomSwitch.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/26.
//

import Foundation
import SwiftUI

struct Switch : View{
    var isOn:Bool = false
    var thumbColor:Color = Color.app.white
    var activeColor:Color = Color.app.green
    var defaultColor:Color = Color.app.grey200
  
    let action: (Bool) -> Void
   
    var body: some View {
        Button(action: {
            self.action(!self.isOn)
        }){
            ZStack(alignment: .leading){
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(self.isOn ? self.activeColor : self.defaultColor)
                        .modifier(MatchParent())
                }
                .frame(width: 56, height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                Circle()
                    .fill(self.thumbColor)
                    .frame(width: 26, height: 26, alignment: .leading)
                    .offset(x: self.isOn ? 28 : 2)
                
            }
            
        }
    }
}
#if DEBUG
struct Switch_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            Switch(isOn: true){ isOn in
                
            }
            Switch(isOn: false){ isOn in
                
            }
        }
        
    }
}
#endif
