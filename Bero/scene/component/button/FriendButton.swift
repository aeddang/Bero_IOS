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
        case request, requested, accept, reject, delete, chat, move
        var icon:String?{
            switch self {
            case .request : return Asset.icon.add_friend
            case .requested : return Asset.icon.add_friend
            case .delete: return Asset.icon.remove_friend
            case .chat: return Asset.icon.chat
            case .accept: return Asset.icon.check
            case .reject: return Asset.icon.close
            case .move: return Asset.icon.search
            }
        }
        var bgColor:Color{
            switch self {
            case .move : return Color.brand.primary
            case .requested : return Color.app.grey300
            case .delete, .reject: return Color.app.black
            case .accept, .request,.chat : return Color.brand.primary
            }
        }
        
        
        var iconColor:Color{
            switch self {
            case .accept, .request, .chat, .move : return Color.brand.primary
            case .reject, .delete : return Color.app.black
            default : return Color.app.grey300
            }
        }
        var textColor:Color{
            switch self {
            case .move : return Color.brand.primary
            default : return Color.app.white
            }
        }
        var text:String{
            switch self {
            case .move : return String.button.viewProfile
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
            case .delete, .move : return .stroke
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
    var userName:String? = nil
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
                iconType: .template,
                text: self.funcType.text,
                size:self.size,
                radius: self.radius,
                color: self.funcType.bgColor,
                textColor: self.funcType.textColor,
                textSize: self.textSize
            ){_ in
                
                self.action()
            }
        case .icon :
            CircleButton(
                type: self.funcType.icon != nil ? .icon(self.funcType.icon!) : .tiny,
                isSelected: true,
                strokeWidth: Dimen.stroke.regular,
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
        case .move:
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.user)
                    .addParam(key: .id, value:id)
            )
        case .request:
            self.dataProvider.requestData(q: .init(id: id, type: .requestFriend(userId: id)))
        case .requested:
            self.appSceneObserver.event = .toast("Already friend (write the phrase)")
        case .delete:
            self.appSceneObserver.sheet = .select(
                String.alert.friendDeleteConfirm.replace(userName ?? ""),
                String.alert.friendDeleteConfirmText,
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


