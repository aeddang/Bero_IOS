import Foundation
import SwiftUI
extension UserFriendFunctionBox{
    enum Status{
        case none, requestFriend, friend, recieveFriend
        var icon:String{
            switch self {
            case .requestFriend : return Asset.icon.check
            case .friend : return Asset.icon.remove_friend
            case .recieveFriend : return Asset.icon.add_friend
            default : return Asset.icon.add_friend
            }
        }
       
        var bgColor:Color{
            switch self {
            case .requestFriend : return Color.app.grey50
            case .friend : return Color.app.black
            case .recieveFriend : return Color.brand.primary
            default : return Color.brand.primary
            }
        }
        var textColor:Color{
            switch self {
            case .requestFriend : return Color.app.grey300
            case .friend : return Color.app.black
            case .recieveFriend : return Color.app.white
            default : return Color.app.white
            }
        }
        var text:String{
            switch self {
            case .requestFriend : return String.button.requestSent
            case .friend : return String.button.removeFriend
            case .recieveFriend : return String.button.addFriend
            default : return String.button.addFriend
            }
        }
        
        var buttonType:FillButton.ButtonType{
            switch self {
            case .friend : return .stroke
            default : return .fill
            }
        }
    }
    
    
}

struct UserFriendFunctionBox: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    let user:User
   
    var body: some View {
        HStack(spacing:Dimen.margin.micro){
            FillButton(
                type: self.status.buttonType,
                icon: self.status.icon,
                text: self.status.text,
                color: self.status.bgColor,
                textColor: self.status.textColor
            ){_ in
                
            }
            FillButton(
                type: .fill,
                text: String.button.chat,
                color: Color.brand.primary,
                isActive: self.status == .friend
            ){_ in
                
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            
            default : break
            }
        }
        .onAppear{
            
        }
    }
    @State var status:Status = .none
}


