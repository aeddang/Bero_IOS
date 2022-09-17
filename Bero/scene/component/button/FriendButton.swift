//
//  FriendButton.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/09/07.
//

import Foundation
import SwiftUI

extension FriendButton {
    enum ButtonType:String{
        case request, requested, accept, reject, delete
        var icon:String?{
            switch self {
            case .request, .requested : return Asset.icon.check
            case .delete: return Asset.icon.remove_friend
            default : return nil
            }
        }
        var bgColor:Color{
            switch self {
            case .request : return Color.app.white
            case .requested : return Color.app.grey300
            case .delete : return Color.app.grey300
            case .accept : return Color.app.white
            case .reject : return Color.app.grey300
            }
        }
        
        var bgGradient:Gradient?{
            switch self {
            case .request : return Color.app.orangeGradient
            case .accept : return Color.app.orangeGradient
            default : return nil
            }
        }
        
        var textColor:Color{
            switch self {
            case .delete : return Color.app.grey300
            default : return Color.app.white
            }
        }
        var text:String{
            switch self {
            case .request, .requested : return String.button.requestFriend
            case .delete : return String.button.remove
            case .accept : return String.button.accept
            case .reject : return String.button.reject
            }
        }
        var buttonType:FillButton.ButtonType{
            switch self {
            case .delete : return .stroke
            default : return .fill
            }
        }
    }
}
    
struct FriendButton: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var userId:String? = nil
    var type:FriendButton.ButtonType
    var size:CGFloat = Dimen.button.mediumExtra
    var radius:CGFloat = Dimen.radius.thin
    var textSize:CGFloat = Font.size.light
    var body: some View {
        FillButton(
            type: self.type.buttonType,
            icon: self.type.icon,
            text: self.type.text,
            size:self.size,
            radius: self.radius,
            color: self.type.bgColor,
            textColor: self.type.textColor,
            gradient:self.type.bgGradient,
            textSize: self.textSize
        ){_ in
            
            guard let id = userId else {return}
            if id == self.dataProvider.user.snsUser?.snsID {return}
            
            switch type {
            case .request:
                self.dataProvider.requestData(q: .init(id: id, type: .requestFriend(userId: id)))
            case .requested:
                self.appSceneObserver.event = .toast("Already friend (write the phrase)")
            case .delete:
                self.dataProvider.requestData(q: .init(id: id, type: .deleteFriend(userId: id)))
            case .accept:
                self.dataProvider.requestData(q: .init(id: id, type: .acceptFriend(userId: id)))
            case .reject:
                self.dataProvider.requestData(q: .init(id: id, type: .rejectFriend(userId: id)))
            }
        }
    }
}


