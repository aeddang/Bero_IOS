import Foundation
import SwiftUI

struct LvSection: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var user:User
    var body: some View {
        VStack(spacing:0){
            HeartButton(
                type: .big,
                text: "Lv." + self.lvValue.description,
                activeColor: self.lv.color,
                isSelected: true
            ){_ in
                self.appSceneObserver.event = .toast(String.pageText.myLvText2.replace(self.lv.title))
            }
            TextButton(
                type: .box,
                defaultText:String.button.learnMore,
                image: Asset.icon.direction_right,
                imageMode: .template
                ){_ in
                    self.appSceneObserver.event = .toast(String.alert.comingSoon)
            }
            .padding(.top, Dimen.margin.tinyExtra)
            ProgressInfo(
                leadingText: "Lv." + self.lvValue.description,
                trailingText: String.app.exp,
                progress: self.expProgress,
                progressMax: self.expMax,
                color: self.lv.color
            )
            .frame(height: 32)
            .padding(.top, Dimen.margin.regularExtra)
            ZStack{
                Spacer().modifier(MatchHorizontal(height: 0))
                Text(self.needInfo)
                    .modifier(RegularTextStyle(size: Font.size.thin,color: Color.brand.primary))
                    .padding(.horizontal, Dimen.margin.light)
                    .padding(.vertical, Dimen.margin.tiny)
                    
                    .multilineTextAlignment(.center)
            }
            .background(Color.app.orangeSub)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
            .padding(.top, Dimen.margin.regularUltra)
        }
        .onReceive(self.user.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .updatedPlayData :
                self.updatedLv()
            default : break
            }
        }
        .onAppear(){
            self.updatedLv()
        }
    }
    @State var lvValue:Int = 1
    @State var lv:Lv = .purple
    @State var exp:Double = 0
    @State var expMax:Double = 0
    @State var expProgress:Double = 0
    @State var needInfo:String = ""
    private func updatedLv(){
        self.lvValue = user.lv
        self.lv = Lv.getLv(user.lv)
        let exp = user.exp
        let current:Double = user.prevExp
        let progress = exp - current
        self.exp = exp
        self.expMax = user.prevExp + user.nextExp
        self.expProgress = min(progress, expMax)
        
        if self.exp == 0 {
            self.needInfo = String.pageText.myLvText3.replace(String.app.appName)
        } else {
            let needExp = self.expMax - self.exp
            self.needInfo = String.pageText.myLvText4.replace(needExp.toInt().description)
        }
    }
}


