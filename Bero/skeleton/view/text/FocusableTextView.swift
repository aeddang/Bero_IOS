//
//  FocusableTextField.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/27.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct FocusableTextView: UIViewRepresentable {
    @Binding var text:String
    var placeholder: String = ""
    var isfocus:Bool = false
    var usefocusAble:Bool = true
    var isSecureTextEntry:Bool = false
    
    var keyboardType: UIKeyboardType = .default
    var returnKeyType: UIReturnKeyType = .done
    
    var textAlignment:NSTextAlignment = .left
    var textModifier:TextModifier = RegularTextStyle().textModifier
    
    var limitedLine: Int = 1
    var limitedTextLength: Int = -1
    
    var inputLimited: (() -> Void)? = nil
    var inputChange: ((_ text:String, _ size:CGSize) -> Void)? = nil
    var inputChanged: ((_ text:String, _ size:CGSize) -> Void)? = nil
    var inputCopmpleted: ((_ text:String) -> Void)? = nil
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.textColor = textModifier.color.uiColor()
        textView.font = UIFont(name: textModifier.family, size: textModifier.size)
        textView.keyboardType = self.keyboardType
        textView.returnKeyType = self.returnKeyType
        textView.delegate = context.coordinator
        textView.autocorrectionType = .yes
        textView.textAlignment = self.textAlignment
        textView.sizeToFit()
        textView.textContentType = .oneTimeCode
        textView.isSecureTextEntry = self.isSecureTextEntry
        textView.backgroundColor = UIColor.clear
        if limitedLine != -1 {
            textView.textContainer.maximumNumberOfLines = self.limitedLine
        }
        textView.text = self.text
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
       
        if self.usefocusAble {
            if self.isfocus {
                if !uiView.isFocused {
                    uiView.becomeFirstResponder()
                }
                
            } else {
                if uiView.isFocused {
                    uiView.resignFirstResponder()
                }
            }
        }
        if uiView.text != self.text { uiView.text = self.text }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: FocusableTextView
        init(_ parent: FocusableTextView) {
            self.parent = parent
        }
       
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if self.parent.limitedLine == 1 && text == "\n" {
                guard let  inputCopmpleted = self.parent.inputCopmpleted else { return true }
                inputCopmpleted(textView.text)
                return false
            }
            if let currentText = textView.text,
                let textRange = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: textRange, with: text)
                if self.parent.limitedTextLength != -1 {
                    if updatedText.count > self.parent.limitedTextLength {
                        parent.inputLimited?()
                        return false
                    }
                }
                self.parent.inputChange?(updatedText, textView.contentSize)
            }
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
            self.parent.inputChanged?(textView.text , textView.contentSize)
        }
       
    
        func updatefocus(textView: UITextView) {
            textView.becomeFirstResponder()
        }
       

        func textViewShouldReturn(_ textView: UITextView) -> Bool {
            guard let  inputCopmpleted = self.parent.inputCopmpleted else { return true }
            inputCopmpleted(textView.text ?? "")
            return false
        
        }

    }
}


