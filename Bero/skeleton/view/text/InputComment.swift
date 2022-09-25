import Foundation
import SwiftUI


struct InputComment: PageView {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var title:String? = nil
    @Binding var input:String
    var placeHolder:String = ""
    var isFocus:Bool = true
    var textModifier:TextModifier = RegularTextStyle(size: Font.size.light).textModifier
    var onFocus:(() -> Void)? = nil
    var onChange:((String) -> Void)? = nil
    var onAction:(() -> Void)? = nil
    
    var body: some View {
       
        HStack(alignment: .center, spacing:Dimen.margin.thin){
            HStack(alignment: .center, spacing:Dimen.margin.micro){
                /*
                 ZStack(alignment: .trailing){
                 FocusableTextField(
                 text:self.$input,
                 keyboardType: .default,
                 returnVal: .done,
                 placeholder: self.placeHolder,
                 textAlignment: .left,
                 maxLength: 50,
                 textModifier:self.textModifier,
                 isfocus: self.isFocus,
                 inputChanged: self.onChange,
                 inputCopmpleted: { _ in
                 self.onAction?()
                 }
                 )
                 }
                 .modifier(MatchParent())
                 .clipped()
                 .onTapGesture {
                 self.onFocus?()
                 }
                 */
                FocusableTextView(
                    text:self.$input,
                    placeholder: self.placeHolder,
                    isfocus: self.isFocus,
                    keyboardType: .default,
                    returnKeyType: .default,
                    textAlignment: .left,
                    textModifier:self.textModifier,
                    limitedLine: self.limitedLine,
                    limitedTextLength: 100,
                    inputChanged: { text, _ in
                        self.onResize()
                        self.onChange?(text)
                    },
                    inputCopmpleted: { _ in
                        self.onAction?()
                    }
                )
                .background(Color.transparent.clearUi)
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
                    .fixedSize()
                }
                Button(action: {
                    self.onAction?()
                }) {
                    Image(Asset.icon.send)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(!self.input.isEmpty ? Color.brand.primary : Color.app.grey200)
                        .frame(width: Dimen.icon.light,
                               height: Dimen.icon.light)
                }
                .fixedSize()
            }
            .padding(.all, Dimen.margin.tiny)
            .modifier(MatchParent())
            .background(Color.app.grey50)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.heavy))
            .overlay(
                RoundedRectangle(
                    cornerRadius: Dimen.radius.heavy, style: .circular)
                .stroke( Color.app.grey200 , lineWidth: Dimen.stroke.light )
            )
            .padding(.vertical, Dimen.margin.tiny)
            .modifier(MatchHorizontal(height:max( Dimen.app.chatBox, self.height) ))
        }
        .onReceive( [self.input].publisher ) { input in
            if !self.input.isEmpty {return}
            if self.height == 0  { return }
            DispatchQueue.main.async {
                self.height = 0
            }
        }
        
    }
    @State var limitedLine:Int = 0
    @State var isInputLimited:Bool = false
    @State var height:CGFloat = 0
    private func onResize(){
        let w = self.sceneObserver.screenSize.width
            - (Dimen.icon.light * 2) - (Dimen.margin.micro * 2) - (Dimen.margin.tiny * 2) - (Dimen.app.pageHorinzontal * 2)
        let h = self.textModifier.getTextLineHeight()
        let textH = self.textModifier.getTextHeight(self.input, screenWidth: w)
        let line = textH / h
        DataLog.d("line " + line.description)
        self.limitedLine = Int(line)
        self.height = textH + (Dimen.margin.tiny * 2) + (Dimen.margin.tiny * 2)
    }
    
}

#if DEBUG
struct InputComment_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            InputComment(
                input: .constant(""),
                isFocus: false
            )
            .environmentObject(PagePresenter()).frame(width:240,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif

