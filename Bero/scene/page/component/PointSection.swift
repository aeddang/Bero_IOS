import Foundation
import SwiftUI

struct PointSection: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var user:User
    var body: some View {
        VStack(spacing:Dimen.margin.regular){
            HStack(spacing: Dimen.margin.tiny){
                Text(self.point.description)
                    .modifier(SemiBoldTextStyle(
                        size: Dimen.icon.heavyExtra,
                        color: Color.app.black
                    ))
                    .frame(height: Dimen.icon.heavyExtra)
                Image(Asset.icon.point)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.heavyExtra, height: Dimen.icon.heavyExtra)
            }
            TextButton(
                type: .box,
                defaultText:String.button.learnMore,
                image: Asset.icon.direction_right,
                imageMode: .template
                ){_ in
                    self.appSceneObserver.event = .toast(String.alert.comingSoon)
                }

            FillButton(
                type: .fill,
                icon: Asset.icon.store,
                text: String.pageText.myPointText2,
                color: Color.app.grey200
                
            ){_ in
                self.appSceneObserver.event = .toast(String.pageText.myPointText2)
            }
        }
        .onReceive(self.user.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .updatedPlayData :
                self.updatedPoint()
            default : break
            }
        }
        .onAppear(){
            self.updatedPoint()
        }
    }
   
    @State var point:Int = 0
    
    private func updatedPoint(){
        self.point = self.user.point
    }
}


