import Foundation
import SwiftUI

struct MyLevelSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var body: some View {
        VStack(spacing:0){
            TitleTab(type:.section, title: String.pageText.myLv, buttons:[.viewMore])
            { type in
                switch type {
                case .viewMore : break
                default : break
                }
            }
            ProgressInfo(
                leadingText: self.leadingText,
                trailingText: "EXP",
                progress: self.progress,
                progressMax: self.progressMax)
            .padding(.top, Dimen.margin.tiny)
            SelectButton(
                type: .tiny,
                icon: Asset.icon.coin,
                isOriginIcon: true,
                text: self.pointInfo,
                bgColor: Color.app.orangeSub2,
                isSelected: true
            ){_ in
                
            }
            .padding(.top, Dimen.margin.regularExtra)
        }
        .onReceive(self.dataProvider.user.$event){ evt in
            guard let evt = evt else {return}
           
            switch evt {
            case .updatedPlayData :
                self.updated()
            default : break
            }
        }
        .onAppear(){
            self.updated()
        }
    }
    @State var leadingText:String? = nil
    @State var progress:Double = 0
    @State var progressMax:Double = 0
    @State var pointInfo:String = ""
    
    private func updated(){
        let user = self.dataProvider.user
        self.leadingText = "Lv." + user.lv.description
        self.progress = user.exp
        self.progressMax = user.nextExp
        self.pointInfo = String.pageText.myCurrentPoint.replace(user.point.description)
    }
}


