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
        
        func getStroke(circleButtontype:CircleButton.ButtonType)->CGFloat{
            switch circleButtontype {
            case .image : return Dimen.stroke.heavy
            default : return Dimen.stroke.regular
            }
        }
        
    }
    let id:String
    var type:ProfileType = .pet
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
                        strokeWidth: self.type.getStroke(circleButtontype: type),
                        defaultColor: Color.app.black,
                        activeColor: Color.brand.primary
                    ){ _ in
                        self.buttonAction?()
                    }
                    .padding(.leading, Dimen.profile.mediumUltra - Dimen.margin.light)
                }
            }
            .modifier(MatchHorizontal(height: self.imageSize ?? Dimen.profile.mediumUltra))
            if let name = self.name {
                Text(name)
                    .modifier(SemiBoldTextStyle(
                        size: Font.size.tiny,
                        color: Color.app.black
                    ))
                    .lineLimit(1)
                    .frame(width: self.imageSize ?? Dimen.profile.mediumUltra)
                    
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
