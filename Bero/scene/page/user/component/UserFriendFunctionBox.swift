import Foundation
import SwiftUI


struct UserFriendFunctionBox: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    let user:User
   
    var body: some View {
        HStack(spacing:Dimen.margin.micro){
            ForEach(self.currentStatus.buttons.filter{$0 != .delete}, id:\.rawValue){ btn in
                FriendButton(
                    userId:self.user.currentProfile.userId,
                    type: btn
                )
            }
            FillButton(
                type: .fill,
                icon : self.currentStatus == .friend ? Asset.icon.send : nil,
                text: String.button.chat,
                color: Color.brand.primary,
                isActive: self.currentStatus == .friend
            ){_ in
                if self.currentStatus != .friend { return }
                self.appSceneObserver.event = .sendChat(userId: self.user.currentProfile.userId)
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .requestFriend(let userId) :
                if self.user.currentProfile.userId == userId {
                    self.currentStatus = .requestFriend
                }
            case .acceptFriend(let userId) :
                if self.user.currentProfile.userId == userId {
                    self.currentStatus = .friend
                }
            case .rejectFriend(let userId), .deleteFriend(let userId) :
                if self.user.currentProfile.userId == userId {
                    self.currentStatus = .norelation
                }
            default : break
            }
        }
        .onAppear{
            self.currentStatus = self.user.currentProfile.status
        }
    }
    @State var currentStatus:FriendStatus = .norelation
}


