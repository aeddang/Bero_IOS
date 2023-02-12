
import Foundation
import SwiftUI
import FirebaseAnalytics
struct SortButton: View, PageProtocol{
    enum ButtonType{
        case fill, stroke, strokeFill
        var strokeWidth:CGFloat{
            switch self {
            case .fill : return 0
            case .stroke: return Dimen.stroke.light
            case .strokeFill: return Dimen.stroke.light
            }
        }
        
        func strokeColor(_ color:Color) ->Color{
            switch self {
            case .fill : return Color.app.white
            case .stroke : return color.opacity(0.3)
            case .strokeFill : return color.opacity(0.5)
            }
        }
        
        func bgColor(_ color:Color) ->Color{
            switch self {
            case .fill : return color
            case .stroke : return Color.app.white
            case .strokeFill : return color.opacity(0.15)
            }
        }
        
        func textColor(_ color:Color) ->Color{
            switch self {
            case .fill : return Color.app.white
            case .stroke : return color
            case .strokeFill : return color
            }
        }
    }
    enum SizeType{
        case small, big
        var iconSize:CGFloat{
            switch self {
            case .small : return Dimen.icon.thin
            case .big : return Dimen.icon.light
            }
        }
        
        var textSize:CGFloat{
            switch self {
            case .small : return Font.size.thin
            case .big : return Font.size.light
            }
        }
        
        var radius:CGFloat{
            switch self {
            case .small : return Dimen.radius.light
            case .big : return Dimen.radius.medium
            }
        }
        
        var marginVertical:CGFloat{
            switch self {
            case .small : return Dimen.radius.micro
            case .big : return Dimen.margin.microUltra
            }
        }
        var marginHorizontal:CGFloat{
            switch self {
            case .small : return Dimen.margin.tiny
            case .big : return Dimen.margin.regularExtra
            }
        }
        
        var spacing:CGFloat{
            switch self {
            case .small : return Dimen.margin.micro
            case .big : return Dimen.margin.tinyExtra
            }
        }
    }
    var type:ButtonType = .fill
    var sizeType:SizeType = .big
    var userProgile:UserProfile? = nil
    var petProgile:PetProfile? = nil
    var icon:String? = nil
    var iconType:Image.TemplateRenderingMode = .template
    var text:String
    var color:Color = Color.app.black
    var isSort:Bool = true
    var isSelected = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
            let parameters = [
                "buttonType": self.tag,
                "buttonText": text
            ]
            Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
        }) {
            ZStack{
                HStack(spacing:self.sizeType.spacing){
                    if let profile = self.petProgile {
                        ProfileImage(
                            id : "",
                            image:profile.image,
                            imagePath: profile.imagePath,
                            size: self.sizeType.iconSize,
                            emptyImagePath: Asset.image.profile_dog_default
                        )
                    }
                    if let profile = self.userProgile {
                        ProfileImage(
                            id : "",
                            image:profile.image,
                            imagePath: profile.imagePath,
                            size: self.sizeType.iconSize,
                            emptyImagePath: Asset.image.profile_user_default
                        )
                    }
                    if let icon = self.icon {
                        switch self.iconType {
                        case .template :
                            Image(icon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(self.type.textColor(self.color))
                                .frame(width:self.sizeType.iconSize,height: self.sizeType.iconSize)
                        default :
                            Image(icon)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width:self.sizeType.iconSize,height: self.sizeType.iconSize)
                                .padding(.all, Dimen.margin.micro)
                                .background(Color.app.white)
                                .clipShape(Circle())
                        }
                    }
                    if !self.text.isEmpty {
                        Text(self.text)
                            .lineLimit(1)
                            .modifier(MediumTextStyle(
                                size: self.sizeType.textSize,
                                color: self.type.textColor(self.color)
                            ))
                        if self.isSort {
                            Image(Asset.icon.direction_down)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(self.type.textColor(self.color))
                                    .rotationEffect(.degrees(self.isSelected ? 180 : 0))
                                    .frame(width:self.sizeType.iconSize,height: self.sizeType.iconSize)
                        }
                    }
                    
                }
                .padding(.leading, self.text.isEmpty || self.iconType == .original
                         ? self.sizeType.marginVertical : self.sizeType.marginHorizontal)
                .padding(.trailing, self.text.isEmpty || self.isSort
                         ? self.sizeType.marginVertical : self.sizeType.marginHorizontal)
                .padding(.vertical, self.sizeType.marginVertical)
            }
            .background(self.type.bgColor(color))
            .clipShape(RoundedRectangle(cornerRadius: self.sizeType.radius))
            .overlay(
                RoundedRectangle(cornerRadius: self.sizeType.radius)
                    .strokeBorder(
                        self.type.strokeColor(self.color),
                        lineWidth: self.type.strokeWidth
                    )
            )
            
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
#if DEBUG
struct SortButtonButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SortButton(
                type: .fill,
                sizeType: .big,
                icon: Asset.icon.paw,
                text: "Chip",
                color: Color.app.orange,
                isSelected: true
            )
            {
                
            }
            SortButton(
                type: .fill,
                sizeType: .big,
                icon: Asset.icon.paw,
                iconType: .original,
                text: "Chip",
                color: Color.app.orange,
                isSort: false
            )
            {
                
            }
            
            SortButton(
                type: .stroke,
                sizeType: .small,
                icon: Asset.icon.paw,
                text: "",
                color: Color.app.orange,
                isSelected: false
            )
            {
                
            }
            
            SortButton(
                type: .strokeFill,
                sizeType: .small,
                icon: Asset.icon.paw,
                text: "Chip",
                color: Color.app.orange,
                isSelected: false
            )
            {
                
            }
            SortButton(
                type: .stroke,
                sizeType: .small,
                icon: Asset.icon.paw,
                text: "Chip",
                color: Color.app.grey300,
                isSelected: false
            )
            {
                
            }
            SortButton(
                type: .fill,
                sizeType: .small,
                icon: Asset.icon.paw,
                text: "Chip",
                color: Color.app.grey200,
                isSelected: false
            )
            {
                
            }
        }
        .padding(.all, 10)
    }
}
#endif
