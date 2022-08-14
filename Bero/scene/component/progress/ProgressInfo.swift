//
//  ProgressInfo.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/06.
//
import SwiftUI
import Foundation

struct ProgressInfo:PageView{
    var leadingText:String? = nil
    var trailingText:String = ""
    var progress:Double = 0
    var progressMax:Double = 0
    var body: some View {
        VStack(alignment: .leading, spacing:Dimen.margin.tinyExtra){
            HStack(alignment: .center, spacing: 0){
                if let text = self.leadingText {
                    Text(text)
                        .modifier(BoldTextStyle(
                            size: Font.size.thin,
                            color: Color.brand.primary
                        ))
                }
                Spacer().modifier(MatchHorizontal(height: 0))
                Text(self.progress.toInt().description)
                    .modifier(RegularTextStyle(
                        size: Font.size.tiny,
                        color: Color.brand.primary
                    ))
                Text("/" + self.progressMax.toInt().description + trailingText)
                    .modifier(RegularTextStyle(
                        size: Font.size.tiny,
                        color: Color.app.grey300
                    ))
            }
            ProgressSlider(
                progress:  Float(self.progress / self.progressMax),
                thumbSize: 0
            )
        }
    }
}
#if DEBUG
struct ProgressInfo_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            ProgressInfo(
                leadingText: "Lv.13",
                trailingText: "EXP",
                progress: 70,
                progressMax: 100)
        }
    }
}
#endif
