//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct MultiProfile: PageComponent{
    enum ProfileType{
        case pet, user
        var emptyImage:String{
            switch self {
            case .pet : return Asset.image.profile_dog_default
            case .user : return Asset.image.profile_user_default
            }
        }
        func getButtonSelectStatus(circleButtontype:CircleButton.ButtonType)->Bool{
            switch circleButtontype {
            case .text, .image : return true
            default : return false
            }
        }
        
        func getStroke(circleButtontype:CircleButton.ButtonType, size:SizeType)->CGFloat{
            switch circleButtontype {
            case .image : return size == .small ? Dimen.stroke.regular : Dimen.stroke.heavy
            default : return Dimen.stroke.regular
            }
        }
        
    }
    enum SizeType{
        case small, big
        var imageSize:CGFloat{
            switch self {
            case .big : return Dimen.profile.mediumUltra
            case .small : return Dimen.profile.thin
            }
        }
    }
    
    var id:String = UUID().uuidString
    var type:ProfileType = .pet
    var sizeType:SizeType = .big
    var circleButtontype:CircleButton.ButtonType? = nil
    var image:UIImage? = nil
    var imagePath:String? = nil
    var imageSize:CGFloat? = nil
    var name:String? = nil
    var buttonAction: (() -> Void)? = nil
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            ZStack(alignment: .bottom){
                ProfileImage(
                    id : self.id,
                    image: self.image,
                    imagePath: self.imagePath,
                    size: self.imageSize ?? Dimen.profile.mediumUltra,
                    emptyImagePath: self.type.emptyImage
                )
                if let type = self.circleButtontype {
                    CircleButton(
                        type: type,
                        isSelected: self.type.getButtonSelectStatus(circleButtontype: type),
                        strokeWidth: self.type.getStroke(circleButtontype: type, size:self.sizeType),
                        defaultColor: Color.app.black,
                        activeColor: Color.brand.primary
                    ){ _ in
                        self.buttonAction?()
                    }
                    .padding(.leading, (self.imageSize ?? self.sizeType.imageSize) - Dimen.margin.light)
                }
            }
            .modifier(MatchHorizontal(height: self.imageSize ?? self.sizeType.imageSize))
            if let name = self.name {
                Text(name)
                    .modifier(SemiBoldTextStyle(
                        size: Font.size.tiny,
                        color: Color.app.black
                    ))
                    .lineLimit(1)
                    .frame(width: self.imageSize ?? self.sizeType.imageSize)
                    
            }
        }
    }
}



#if DEBUG
struct MultiProfile_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            MultiProfile(
                id: "",
                type: .pet,
                circleButtontype: .icon(Asset.icon.edit),
                image: nil,
                imagePath: nil,
                name: "name"
            ){
                
            }
            MultiProfile(
                id: "",
                type: .user,
                sizeType: .small,
                circleButtontype: .image("", size: Dimen.icon.light),
                image: nil,
                imagePath: nil,
                imageSize: Dimen.profile.thin,
                name: "multiProfile"
            ){
                
            }
            MultiProfile(
                id: "",
                type: .pet,
                circleButtontype: .text("Lv.99"),
                image: nil,
                imagePath: nil,
                name: "name"
            ){
                
            }
            
            MultiProfile(
                id: "",
                type: .pet,
                circleButtontype: .image(""),
                image: nil,
                imagePath: nil,
                name: "name"
            ){
                
            }
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
