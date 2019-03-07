//
//  textField.swift
//  MalaBes
//
//  Created by PUNDSK006 on 4/26/17.
//  Copyright © 2017 Intechcreative Pvt. Ltt. All rights reserved.
//

import Foundation
import UIKit

extension UITextField
{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    @IBDesignable
    class PaddingTextField: UITextField {
        
        @IBInspectable var paddingLeft: CGFloat = 0
        @IBInspectable var paddingRight: CGFloat = 0
        
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return CGRect(x: bounds.origin.x + paddingLeft, y: bounds.origin.y, width: bounds.size.width - paddingLeft - paddingRight, height: bounds.size.height)
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return textRect(forBounds: bounds)
        }
    }
    
    func setTintAndTextColor()
    {
        self.tintColor = color.themeDarkGray
        self.textColor = color.themeDarkGray;
    }
    
    
    func setLeftIcon(_ icon: UIImage) {
        
        let padding = 8
        let size = 20
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        leftView = outerView
        leftViewMode = .always
        
        self.spellCheckingType = UITextSpellCheckingType.no
        self.autocorrectionType = UITextAutocorrectionType.no
        self.tintColor = color.themeDarkGray
        //self.textColor = color.txtColor;
        self.rightViewMode = UITextField.ViewMode.always
        self.clearButtonMode = .whileEditing
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction()  {
        self.resignFirstResponder()
    }
    
    func setLeftSpace()
    {
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width:20, height: 20))
        leftView = outerView
        leftViewMode = .always
        
        self.spellCheckingType = UITextSpellCheckingType.no
        self.autocorrectionType = UITextAutocorrectionType.no
        self.tintColor = UIColor.gray
        self.textColor = color.themeDarkGray;
        self.rightViewMode = UITextField.ViewMode.always
        self.clearButtonMode = .whileEditing
    }
    
    func setRightIcon(_ icon: UIImage) {
        
        let padding = 8
        let size = 25
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        rightView = outerView
        rightViewMode = .always
        
        self.spellCheckingType = UITextSpellCheckingType.no
        self.autocorrectionType = UITextAutocorrectionType.no
        self.tintColor = UIColor.gray
        self.textColor = color.themeDarkGray;
        self.leftViewMode = UITextField.ViewMode.always
       
    }
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
}

