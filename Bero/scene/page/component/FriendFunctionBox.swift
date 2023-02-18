import Foundation
import SwiftUI


struct FriendFunctionBox: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var userId:String
    var status:FriendStatus = .norelation
    var isSimple:Bool = false
    var body: some View {
        HStack(spacing:Dimen.margin.micro){
            ForEach(self.currentStatus.buttons.filter{$0 != .delete}, id:\.rawValue){ btn in
                FriendButton(
                    userId:self.userId,
                    funcType: btn
                )
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            switch res.type {
            case .requestFriend(let userId) :
                if self.userId == userId {
                    self.currentStatus = .requestFriend
                }
            case .acceptFriend(let userId) :
                if self.userId == userId {
                    self.currentStatus = .friend
                }
            case .rejectFriend(let userId), .deleteFriend(let userId) :
                if self.userId == userId {
                    self.currentStatus = .norelation
                }
            default : break
            }
        }
        .onAppear{
            self.currentStatus = self.status
        }
    }
    @State var currentStatus:FriendStatus = .norelation
}


