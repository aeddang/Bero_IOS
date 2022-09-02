import Foundation
import SwiftUI

struct TitleSection: PageComponent{
    enum TitleType{
        case small, normal, strong
        var titleSize:CGFloat{
            switch self {
            case .small : return Font.size.medium
            default : return Font.size.bold
            }
        }
        var titleFamily:String{
            switch self {
            case .small : return Font.family.medium
            case .normal : return Font.family.semiBold
            case .strong : return Font.family.bold
            }
        }
    }
    @EnvironmentObject var pagePresenter:PagePresenter
    var type:TitleType = .normal
    var icon:String? = nil
    var header:String? = nil
    var title:String? = nil
    var trailer:String? = nil
    var color:Color = Color.app.black
    var action: (() -> Void)? = nil
   
    var body: some View {
        HStack(spacing: Dimen.margin.regularExtra){
            if let icon = self.icon {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.color)
                    .frame(width:Dimen.icon.heavyExtra, height:Dimen.icon.heavyExtra)
            }
            VStack(alignment:.leading, spacing: 0){
                Spacer().modifier(MatchHorizontal(height: 0))
                if let text = self.header{
                    Text(text)
                        .modifier(RegularTextStyle(size: Font.size.thin, color: Color.app.grey400))
                        .multilineTextAlignment(.leading)
                }
                if let title = self.title {
                    Text(title)
                        .font(.custom( self.type.titleFamily, size:  self.type.titleSize))
                        .foregroundColor(self.color)
                        .lineSpacing(2)
                        .multilineTextAlignment(.leading)
                }
                if let text = self.trailer{
                    Text(text)
                        .modifier(RegularTextStyle(size: Font.size.thin, color: Color.app.grey400))
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

#if DEBUG
struct TitleSection_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(spacing:20){
            TitleSection(
                type:.strong,
                icon: Asset.icon.chart,
                header: "bero's",
                title: "Strong",
                trailer: "bero"
            ){
                
            }
            TitleSection(
                type:.small,
                icon: Asset.icon.chart,
                header: "bero's",
                title: "small"
            ){
                
            }
            TitleSection(
                header: "bero's",
                title: "TITLE"
            ){
                
            }
            
            TitleSection(
                title: "TITLE"
            )
        }
        .padding(.all, 20)
    }
}
#endif
