//
//  ProgressInfo.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/06.
//
import SwiftUI
import Foundation

struct Step:PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    var index:Int
    var total:Int
    var body: some View {
        HStack(spacing: Dimen.margin.micro){
            Text("Step " + index.description)
                .modifier(SemiBoldTextStyle(
                    size: Font.size.thin,
                    color: Color.brand.primary
                ))
            Text("of " + self.total.description)
                .modifier(SemiBoldTextStyle(
                    size: Font.size.thin,
                    color: Color.app.grey300
                ))
        }
    }
}
#if DEBUG
struct Step_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            Step(index: 1, total: 8)
        }
    }
}
#endif
