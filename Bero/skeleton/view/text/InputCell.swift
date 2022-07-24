import Foundation
import SwiftUI

extension InputCell{
    static var inputFontSize = Font.size.light
}
struct InputCell: PageView {
    var title:String? = nil
    @Binding var input:String
    var placeHolder:String = ""
    var tip:String? = nil
    var info:String? = nil
    
    var usefocusAble:Bool = true
    var isFocus:Bool = false
    
    var limitedLine:Int = 1
    var limitedTextLength:Int = -1
   
    var keyboardType:UIKeyboardType = .default
    var returnKeyType: UIReturnKeyType = .done
    var isEditable:Bool = true
    var isSecure:Bool = false
    
    var textModifier:TextModifier = RegularTextStyle(size: Font.size.light).textModifier
   
    var actionTitle:String? = nil
    var action:(() -> Void)? = nil
    
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
                HStack(alignment: self.limitedLine == 1 ? .center : .top, spacing:Dimen.margin.micro){
                    if self.isEditable {
                        if !self.usefocusAble {
                            if self.isSecure{
                                SecureField(self.placeHolder, text: self.$input)
                                    .keyboardType(self.keyboardType)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(Color.app.grey100)
                                    .font(.custom(self.textModifier.family, size: self.textModifier.size))
                        
                            }else{
                                TextField(self.placeHolder, text: self.$input)
                                    .keyboardType(self.keyboardType)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(Color.app.grey100)
                                    .font(.custom(self.textModifier.family, size: self.textModifier.size))
                                    
                            }
                            
                        } else {
                            if self.limitedLine == 1 {
                                FocusableTextField(
                                    text: self.$input,
                                    placeholder: self.placeHolder,
                                    isfocus: self.isFocus,
                                    keyboardType: self.keyboardType,
                                    returnKeyType: self.returnKeyType,
                                    textAlignment: .left,
                                    textModifier: self.textModifier,
                                    limitedTextLength: self.limitedTextLength,
                                    inputLimited: {
                                        if !self.isInputLimited {
                                            withAnimation{ self.isInputLimited = true }
                                        }
                                    },
                                    inputChanged: { text in
                                        if self.isInputLimited {
                                            withAnimation{ self.isInputLimited = false }
                                        }
                                    },
                                    inputCopmpleted: { text in
                                        
                                    }
                                )
                                .modifier(MatchHorizontal(height: self.textModifier.size))
                            } else {
                                FocusableTextView(
                                    text:self.$input,
                                    placeholder: "",
                                    isfocus: self.isFocus,
                                    usefocusAble: true,
                                    keyboardType: self.keyboardType,
                                    returnKeyType: self.returnKeyType,
                                    textAlignment: .left,
                                    textModifier:self.textModifier,
                                    limitedLine: self.limitedLine,
                                    limitedTextLength: self.limitedTextLength,
                                    inputLimited: {
                                        if !self.isInputLimited {
                                            withAnimation{ self.isInputLimited = true }
                                        }
                                    },
                                    inputChanged: {text , size in
                                        if self.isInputLimited {
                                            withAnimation{ self.isInputLimited = false }
                                        }
                                    }
                                )
                                .background(Color.transparent.black45)
                                
                            }
                        }
                    }else{
                        Text(self.input)
                        .modifier(MediumTextStyle(
                                    size: Self.inputFontSize,
                            color: Color.app.grey50)
                        )
                        .lineLimit(self.limitedLine)
                        .multilineTextAlignment(.leading)
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
                        .padding(.top, self.limitedLine == 1 ? 0 : Dimen.margin.tiny)
                    }
                }
                .padding(.horizontal, Dimen.margin.tiny)
                .modifier(MatchHorizontal(
                    height: self.textModifier.getTextLineHeight() * CGFloat(self.limitedLine)
                    + (Dimen.margin.tinyExtra*2)
                ))
                .background(Color.app.white)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                .overlay(
                    RoundedRectangle(
                        cornerRadius: Dimen.radius.thin, style: .circular)
                        .stroke( self.isFocus
                                 ? ( self.isInputLimited ? Color.app.red : Color.brand.primary )
                                 : Color.app.grey50 ,
                                 lineWidth: 1 )
                )
                if self.actionTitle != nil{
                    TextButton(
                        defaultText: self.actionTitle!,
                        textModifier:TextModifier(
                            family:Font.family.medium,
                            size:Font.size.thin,
                            color: Color.brand.secondary),
                        isUnderLine: true)
                    {_ in
                        guard let action = self.action else { return }
                        action()
                    }
                }
            }
            if let info = self.info {
                Text(info)
                    .modifier(RegularTextStyle(size: Font.size.thin,color: Color.app.grey300))
                    .multilineTextAlignment(.center)
            }
            
            if let tip = self.tip{
                Text(tip)
                    .modifier(RegularTextStyle(
                        size: Font.size.thin,color: Color.app.red))
                    .padding(.vertical, Dimen.margin.micro)
                    .padding(.horizontal, Dimen.margin.thin)
                    .background(Color.app.red.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
            }
            
        }
    }
    
}

#if DEBUG
struct InputCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            InputCell(
                title: "title",
                input: .constant("ATtestsdssdsdsddsdsdsdssdsdd"),
                tip: "tip",
                info: "info",
                isFocus: true,
                limitedLine : 1,
                actionTitle: "action"
            )
            .environmentObject(PagePresenter()).frame(width:240,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif

