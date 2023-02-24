import Foundation
import SwiftUI


struct InputText: PageView {
    var title:String? = nil
    @Binding var input:String
    var placeHolder:String = ""
    var tip:String? = nil
    var info:String? = nil
    var ussFocusAble:Bool = true
    var isFocus:Bool = true
    
    var limitedLine:Int = 1
    var limitedTextLength:Int = 100
   
    var keyboardType:UIKeyboardType = .default
    var returnKeyType: UIReturnKeyType = .done
    var autocapitalizationType: UITextAutocapitalizationType = .sentences
    var isEditable:Bool = true
    var isSecure:Bool = false
    
    var textModifier:TextModifier = RegularTextStyle(size: Font.size.light).textModifier
    var actionTitle:String? = nil
    var onFocus:(() -> Void)? = nil
    var onChange:((String) -> Void)? = nil
    var onAction:(() -> Void)? = nil
    
    @State private var isInputLimited:Bool = false
    @State private var inputSize:Int = 0
    var body: some View {
        VStack(alignment: .leading, spacing:Dimen.margin.micro){
            if let title = self.title {
                Text(title)
                    .modifier(SemiBoldTextStyle(size: Font.size.light, color: Color.app.black))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack(alignment: .center, spacing:Dimen.margin.thin){
                VStack(alignment: .trailing, spacing: Dimen.margin.micro){
                    HStack(alignment: self.limitedLine == 1 ? .center : .top, spacing:Dimen.margin.micro){
                        if self.isEditable {
                            if self.ussFocusAble {
                                if self.limitedLine <= 1 {
                                    FocusableTextField(
                                        text:self.$input,
                                        keyboardType: self.keyboardType,
                                        returnVal: self.returnKeyType,
                                        autocapitalizationType: self.autocapitalizationType,
                                        placeholder: self.placeHolder,
                                        textAlignment: .left,
                                        maxLength: self.limitedTextLength,
                                        textModifier:self.textModifier,
                                        isfocus: self.isFocus,
                                        isSecureTextEntry: self.isSecure,
                                        inputChanged: self.onChange,
                                        inputCopmpleted: { _ in
                                            self.onAction?()
                                        }
                                    )
                                    .frame(height : self.textModifier.getTextLineHeight() * CGFloat(self.limitedLine))
                                    .onTapGesture {
                                        self.onFocus?()
                                    }
                                } else {
                                    FocusableTextView(
                                        text:self.$input,
                                        placeholder: self.placeHolder,
                                        isfocus: self.isFocus,
                                        isSecureTextEntry: self.isSecure,
                                        keyboardType: self.keyboardType,
                                        returnKeyType: self.returnKeyType,
                                        autocapitalizationType: self.autocapitalizationType,
                                        textAlignment: .left,
                                        textModifier:self.textModifier,
                                        limitedLine: self.limitedLine,
                                        limitedTextLength: self.limitedTextLength,
                                        inputChanged: { text, _ in
                                            self.inputSize = text.count
                                            self.onChange?(text)
                                        },
                                        inputCopmpleted: { _ in
                                            self.onAction?()
                                        }
                                    )
                                    .frame(height : self.textModifier.getTextLineHeight() * CGFloat(self.limitedLine))
                                    .onTapGesture {
                                        self.onFocus?()
                                    }
                                }
                            } else {
                                ZStack{
                                    Spacer().modifier(MatchParent())
                                    if self.isFocus {
                                        if self.isSecure{
                                            SecureField(self.placeHolder, text: self.$input)
                                                .keyboardType(self.keyboardType)
                                                .multilineTextAlignment(.leading)
                                                .foregroundColor(Color.app.grey100)
                                                .font(.custom(self.textModifier.family, size: self.textModifier.size))
                                    
                                        } else {
                                            TextEditor(text: self.$input)
                                                .font(.custom(textModifier.family, size: textModifier.size))
                                                .foregroundColor(textModifier.color)
                                                
                                                .lineLimit(limitedLine)
                                                .multilineTextAlignment(.leading)
                                                //.autocapitalization(.words)
                                                //.disableAutocorrection(true)
                                                .onChange(of: self.input) { value in
                                                    
                                                    self.onChange?(value)
                                                }
                                                .keyboardType(self.keyboardType)
                                             
                                        }
                                    }
                                }
                            }
                        }else{
                            Text(self.input)
                                .font(.custom(textModifier.family, size: textModifier.size))
                                .foregroundColor(textModifier.color.opacity(0.7))
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
                    .background(self.limitedLine <= 1 ? Color.app.white : Color.app.grey100)
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: Dimen.radius.thin, style: .circular)
                            .stroke( self.isFocus
                                     ? ( self.isInputLimited ? Color.app.red : Color.brand.primary )
                                     : Color.app.grey200 ,
                                     lineWidth: 1 )
                    )
                    if self.limitedLine > 1 {
                        Text("(")
                            .font(.custom(Font.family.regular, size: Font.size.thin))
                            .foregroundColor(Color.app.grey300)
                        + Text(self.inputSize.description)
                            .font(.custom(Font.family.regular, size: Font.size.thin))
                            .foregroundColor(Color.brand.primary)
                        + Text("/" + self.limitedTextLength.description + ")")
                            .font(.custom(Font.family.regular, size: Font.size.thin))
                            .foregroundColor(Color.app.grey300)
                    }
                }
                
                if let title = self.actionTitle {
                    TextButton(
                        defaultText:title,
                        textModifier:TextModifier(
                            family:Font.family.medium,
                            size:Font.size.thin,
                            color: Color.brand.secondary),
                        isUnderLine: true)
                    {_ in
                        guard let action = self.onAction else { return }
                        action()
                    }
                }
            }
            if let info = self.info {
                Text(info)
                    .modifier(RegularTextStyle(size: Font.size.thin,color: Color.app.grey400))
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
        .onAppear(){
            self.inputSize = self.input.count
        }
    }
    
}

#if DEBUG
struct InputText_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            InputText(
                title: "title",
                input: .constant("ATtestsdssdsdsd"),
                tip: "tip",
                info: "info",
                isFocus: true,
                limitedLine : 5,
                actionTitle: "action"
            )
            .environmentObject(PagePresenter()).frame(width:240,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif

