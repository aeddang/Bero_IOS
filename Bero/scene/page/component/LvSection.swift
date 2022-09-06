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
            ZStack{
                Text(self.lv.title)
                    .modifier(RegularTextStyle(size: Font.size.thin,color: Color.app.grey400))
                    .padding(.vertical,  Dimen.margin.tinyExtra)
                    .padding(.horizontal,  Dimen.margin.light)
                    .multilineTextAlignment(.center)
            }
            .background(Color.app.whiteDeepLight)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
            .padding(.top, Dimen.margin.tinyExtra)
            ProgressInfo(
                leadingText: "Lv." + self.lvValue.description,
                trailingText: String.app.exp,
                progress: self.expProgress,
                progressMax: Lv.expRange,
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
    @State var nextExp:Double = 0
    @State var expProgress:Double = 0
    @State var needInfo:String = ""
    private func updatedLv(){
        self.lvValue = user.lv
        self.lv = Lv.getLv(user.lv)
        let exp = user.exp
        let nextExp = user.nextExp
        let current:Double = Double(user.lv-1) * Lv.expRange
        let progress = exp - current
        self.exp = exp
        self.nextExp = nextExp
        self.expProgress = progress
        
        if self.exp == 0 {
            self.needInfo = String.pageText.myLvText3.replace(String.app.appName)
        } else {
            let needExp = self.nextExp - self.exp
            self.needInfo = String.pageText.myLvText4.replace(needExp.description)
        }
    }
}

