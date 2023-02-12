//
//  ReflashSpinner.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/05.
//
import Foundation
import SwiftUI

struct DragDownArrow: PageComponent {
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var text:String? = nil
    var progressMax:Double = Double(InfinityScrollModel.DRAG_COMPLETED_RANGE)
    var body: some View {
        VStack{
            Image(Asset.icon.direction_up)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(self.progress >= self.progressMax ? Color.brand.primary : Color.app.grey100)
                .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                .rotationEffect(.degrees(max(90,90 * self.progress / self.progressMax)))
            if text != nil {
                Text(text!)
                .modifier(LightTextStyle(
                    size: Font.size.light,
                    color: self.progress >= self.progressMax ? Color.brand.primary : Color.app.grey100))
            }
        }
        .opacity(self.progress / self.progressMax)
        .onReceive(self.infinityScrollModel.$event){evt in
            if #available(iOS 14.0, *) {
                guard let evt = evt else {return}
                switch evt {
                case .pullCancel : withAnimation{ self.progress = 0 }
                default : do{}
                }
            }
        }
        .onReceive(self.infinityScrollModel.$pullPosition){ pos in
            if #available(iOS 14.0, *) {
                if pos < InfinityScrollModel.DRAG_RANGE { return }
                self.progress = Double(pos - InfinityScrollModel.DRAG_RANGE)
                ComponentLog.d("progress " + progress.description, tag: self.tag)
            }
        }
    }//body
    
    @State var progress:Double = 0
}

#if DEBUG
struct DragDownArrow_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            DragDownArrow(
                text:"drag"
            )
            .environmentObject(PagePresenter())
            .environmentObject(Repository())
            .frame(width: 375, height: 500, alignment: .center)
        }
    }
}
#endif

