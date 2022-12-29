//
//  FriendButton.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/09/07.
//

import Foundation
import SwiftUI

extension FriendButton {
    enum ButtonType{
       case fill, icon
    }
    
    enum FuncType:String{
        case request, requested, accept, reject, delete, chat
        var icon:String{
            switch self {
            case .request : return Asset.icon.add_friend
            case .requested : return Asset.icon.add_friend
            case .delete: return Asset.icon.remove_friend
            case .chat: return Asset.icon.chat
            case .accept: return Asset.icon.check
            case .reject: return Asset.icon.close
            }
        }
        var bgColor:Color{
            switch self {
            case .request : return Color.app.white
            case .requested : return Color.app.grey300
            case .delete : return Color.app.grey300
            case .accept : return Color.app.white
            case .reject : return Color.app.grey300
            case .chat : return Color.app.grey500
            }
        }
        
        var bgGradient:Gradient?{
            switch self {
            case .request : return Color.app.orangeGradient
            case .accept : return Color.app.orangeGradient
            default : return nil
            }
        }
        var iconColor:Color{
            switch self {
            case .accept, .request, .chat : return Color.brand.primary
            case .reject, .delete : return Color.app.black
            default : return Color.app.grey300
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
            case .request : return String.button.addFriend
            case .requested : return String.button.request
            case .delete : return String.button.remove
            case .accept : return String.button.accept
            case .reject : return String.button.reject
            case .chat : return String.button.chat
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
    var type:FriendButton.ButtonType = .fill
    var userId:String? = nil
    var funcType:FriendButton.FuncType
    var size:CGFloat = Dimen.button.mediumExtra
    var radius:CGFloat = Dimen.radius.thin
    var textSize:CGFloat = Font.size.light
    var body: some View {
        switch self.type {
        case .fill :
            FillButton(
                type: self.funcType.buttonType,
                icon: self.funcType.icon,
                text: self.funcType.text,
                size:self.size,
                radius: self.radius,
                color: self.funcType.bgColor,
                textColor: self.funcType.textColor,
                gradient:self.funcType.bgGradient,
                textSize: self.textSize
            ){_ in
                
                self.action()
            }
        case .icon :
            CircleButton(
                type: .icon(self.funcType.icon),
                isSelected: true,
                strokeWidth: 2,
                activeColor: self.funcType.iconColor
            ){_ in
                self.action()
            }
        }
        
    }
    
    private func action(){
        guard let id = userId else {return}
        if id == self.dataProvider.user.snsUser?.snsID {return}
        
        switch funcType {
        case .request:
            self.dataProvider.requestData(q: .init(id: id, type: .requestFriend(userId: id)))
        case .requested:
            self.appSceneObserver.event = .toast("Already friend (write the phrase)")
        case .delete:
            self.appSceneObserver.sheet = .select(
                String.alert.friendDeleteConfirm,
                nil,
                [String.app.cancel,String.button.removeFriend],
                isNegative: true){ idx in
                    if idx == 1 {
                        self.dataProvider.requestData(q: .init(id: id, type: .deleteFriend(userId: id)))
                    }
            }
            
        case .accept:
            self.dataProvider.requestData(q: .init(id: id, type: .acceptFriend(userId: id)))
        case .reject:
            self.dataProvider.requestData(q: .init(id: id, type: .rejectFriend(userId: id)))
        case .chat:
            self.appSceneObserver.event = .sendChat(userId: self.userId ?? "")
        }
    }
}


