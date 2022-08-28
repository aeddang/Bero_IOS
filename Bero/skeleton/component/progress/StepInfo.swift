//
//  ProgressInfo.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/06.
//
import SwiftUI
import Foundation

struct StepInfo:PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    var index:Int
    var total:Int
    var image:UIImage? = nil
    var info:String? = nil
    var subInfo:String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            if let img = self.image {
                ProfileImage(
                    id : "",
                    image: img,
                    size: Dimen.profile.light
                )
                .padding(.bottom, Dimen.margin.regularExtra)
            }
            Step(index: self.index, total: self.total)
            if let info = self.info {
                Text(info)
                    .modifier(SemiBoldTextStyle(
                        size: Font.size.bold,
                        color: Color.app.black
                    ))
                .padding(.top, Dimen.margin.tinyExtra)
            }
            if let info = self.subInfo {
                Text(info)
                    .modifier(RegularTextStyle(
                        size: Font.size.thin,
                        color: Color.app.grey400
                    ))
                .padding(.top, Dimen.margin.regular)
            }
        }
    }
}
#if DEBUG
struct StepInfo_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            StepInfo(index: 1, total: 8,
                         image: UIImage(named: Asset.image.profile_dog_default),
                         info: "What is the name of\nyour dog?",
                         subInfo: "What is the name of your dog"
            )
        }
    }
}
#endif
