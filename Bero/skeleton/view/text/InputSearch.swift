import Foundation
import SwiftUI


struct InputSearch: PageView {
    var title:String? = nil
    @Binding var input:String
    var placeHolder:String = ""
    var isFocus:Bool = true
    var textModifier:TextModifier = RegularTextStyle(size: Font.size.light).textModifier
    var onFocus:(() -> Void)? = nil
    var onChange:((String) -> Void)? = nil
    var onAction:(() -> Void)? = nil
    
    @State private var isInputLimited:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing:Dimen.margin.micro){
            if let title = self.title {
                Text(title)
                    .modifier(SemiBoldTextStyle(size: Font.size.light, color: Color.app.black))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack(alignment: .center, spacing:Dimen.margin.thin){
                HStack(spacing:Dimen.margin.micro){
                    FocusableTextField(
                        text:self.$input,
                        keyboardType: .webSearch,
                        returnVal: .search,
                        placeholder: self.placeHolder,
                        textAlignment: .left,
                        maxLength: 30,
                        textModifier:self.textModifier,
                        isfocus: self.isFocus,
                        inputChanged: self.onChange,
                        inputCopmpleted: { _ in
                            self.onAction?()
                        }
                    )
                    .onTapGesture {
                        self.onFocus?()
                    }
                    if !self.input.isEmpty {
                        Button(action: {
                            self.input = ""
                        }) {
                            Image(Asset.icon.erase)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Dimen.icon.light,
                                       height: Dimen.icon.light)
                        }

                    } else {
                        Image(Asset.icon.search)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(self.isFocus ? Color.brand.primary : Color.app.grey200)
                            .frame(width: Dimen.icon.light,
                                   height: Dimen.icon.light)
                    }
                }
                .padding(.horizontal, Dimen.margin.tiny)
                .modifier(MatchHorizontal(height: Dimen.tab.medium))
                .background(Color.app.white)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.heavy))
                .overlay(
                    RoundedRectangle(
                        cornerRadius: Dimen.radius.heavy, style: .circular)
                        .stroke( self.isFocus
                                 ? ( self.isInputLimited ? Color.app.red : Color.brand.primary )
                                 : Color.app.grey200 ,
                                 lineWidth: Dimen.stroke.light )
                )
            }
        }
    }
    
}

#if DEBUG
struct InputSearch_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            InputSearch(
                title: "title",
                input: .constant(""),
                isFocus: true
            )
            .environmentObject(PagePresenter()).frame(width:240,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif

