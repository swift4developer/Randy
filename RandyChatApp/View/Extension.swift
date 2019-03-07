//
//  ViewController_Extension.swift
//  MalaBes
//
//  Created by PUNDSK006 on 4/18/17.
//  Copyright © 2017 Intechcreative Pvt. Ltt. All rights reserved.
//

import Foundation
import UIKit
protocol SortDelegate
{
    func get(SelectedItem : String?)
}

extension UIApplication {
    
    var screenShot: UIImage?  {
        
        if let rootViewController = keyWindow?.rootViewController {
            let scale = UIScreen.main.scale
            let bounds = rootViewController.view.bounds
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale);
            if let _ = UIGraphicsGetCurrentContext() {
                rootViewController.view.drawHierarchy(in: bounds, afterScreenUpdates: true)
                let screenshot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return screenshot
            }
        }
        return nil
    }
    
}


extension UILabel {
    func addImageWith(name: String, behindText: Bool) {
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: name)
        let attachmentString = NSAttributedString(attachment: attachment)
        
        
        guard let txt = self.text else {
            return
        }
        
        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }
    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
}

extension UIViewController{
   
    // MARK: Setting background Img
    static func setBackGroundImg(view : UIView) { //-> UIImageView
        let imageView = UIImageView()
        imageView.image = UIImage(named: "iOS 320x480.png")
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.frame = UIScreen.main.bounds
        view.insertSubview(imageView, at: 0)
    }
   
    
    func createSettingsAlertController(title: String, message: String) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment:"" ), style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment:"" ), style: .default, handler: { action in
            
            if let url = URL(string: UIApplication.openSettingsURLString){
                if #available(iOS 10, *){
                    UIApplication.shared.open(url, options: [:], completionHandler: {
                        (success) in
                    })
                }else{
                    _ = UIApplication.shared.openURL(url)
                }
            }
        })
        controller.addAction(cancelAction)
        controller.addAction(settingsAction)
        return controller
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    //Add Shake animation and Remove Animation
    func addAnimation1(txtField: UITextField){
        txtField.background = nil
        txtField.layer.borderColor = color.themeDarkGray.cgColor
        txtField.layer.borderWidth = 1.0
        txtField.shake()
    }
    
    func removeAnimation1(txtField: UITextField){
        txtField.layer.borderColor = nil
        txtField.layer.borderWidth = 0.0
        txtField.layer.borderColor = UIColor.clear.cgColor
        txtField.layer.borderWidth = 0.0
    }
    
    // MARK:- navigationController :- Set TintColor and Title
    
    func setNaviTitleWithBarTintColor(){
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color.themeDarkGray,  NSAttributedString.Key.font:UIFont(name: fontAndSize.NaviTitleFont, size: fontAndSize.NaviTitleFontSize)!]
        self.navigationController?.navigationBar.barTintColor = color.themeDarkGray
     
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    
    // MARK:- navigationController :- Set Back Button
    
    func setNaviBackButton()
    {
        //Design Of Navigation Bar Back_Button
        let btnBack = UIButton(frame: CGRect(x: 0, y:0, width:22,height: 22))
        btnBack.setImage(UIImage(named:"back"), for: .normal)
        btnBack.addTarget(self,action: #selector(back), for: .touchUpInside)
        let widthConstraint = btnBack.widthAnchor.constraint(equalToConstant: 22)
        let heightConstraint = btnBack.heightAnchor.constraint(equalToConstant: 22)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        let backBarButtonitem = UIBarButtonItem(customView: btnBack)
        let arrLeftBarButtonItems : Array = [backBarButtonitem]
        self.navigationItem.leftBarButtonItems = arrLeftBarButtonItems
    }
    
    // MARK:- navigationController :- Set Design
    func navigationDesign(){
        setNaviTitleWithBarTintColor()
    }
    // MARK:- navigationController :- Set Back Action
    @objc func back(){
        self.navigationController?.popViewController(animated: true)
    }
     // MARK:- default sharing
    func defaultShareTextWithImage(text:String) {
        // image and text to share
        let text = text
        
        // set up activity view controller
        let imageToShare = [text ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }

    func separateImageNameFromUrl(Url:String) -> String {
        let ownerImgUrl = Url
        let array = ownerImgUrl.components(separatedBy: "/")
        var imgName = ""
        if (array.count) > 0{
            imgName = (array.last)!
        }
        return imgName
    }
    
    func isValidDecimal(_ currText: String, _ range : NSRange, _ string: String) -> Bool {
        let replacementText = (currText as NSString).replacingCharacters(in: range, with: string)
        
        // Validate
        return replacementText.isValidDecimal(maximumFractionDigits: 2)
    }
    
    func convertDateFormater(_ date: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss z"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return  dateFormatter.string(from: date!)
        
    }
    
    //MARK:- - NO Internate and No Data Found View
    
    func noInternatViewWithReturnView(imgeFlag:String, lableNoData:String, lableNoInternate: String)-> UIView{
        
        let screenSize: CGRect = UIScreen.main.bounds
        let noIntenateView = UIView(frame: CGRect(x:0, y:0, width: screenSize.width, height: screenSize.height))
        noIntenateView.backgroundColor = UIColor.clear
        // self.view.addSubview(noIntenateView)
        noIntenateView.isUserInteractionEnabled = false
        
        //Button
        let backButton = UIButton()
        backButton.frame = CGRect.init(x: 15, y: 40, width: 30, height: 30)
        backButton.setImage(UIImage(named:"backBalck"), for: .normal)
        backButton.addTarget(self,action: #selector(back), for: .touchUpInside)
        
        var topOfbgView:CGFloat = 100
        var imageName = UIImage(named: "")
        if imgeFlag == "1" {
            imageName = UIImage(named: "noInternate")
        }
        else if imgeFlag == "0" {
            topOfbgView = 150
            imageName = UIImage(named: "white")
        }
        else if imgeFlag == "2" {
            imageName = UIImage(named: "sad_face")
        }
        else if imgeFlag == "3" {
            imageName = UIImage(named: "sad_face") // No Data/Somthing wents Wrong with Back Button
            noIntenateView.addSubview(backButton)
            noIntenateView.isUserInteractionEnabled = true
        }
        else if imgeFlag == "4" {
            imageName = UIImage(named: "noInternate") // No Intenate wents Wrong with Back Button
            noIntenateView.addSubview(backButton)
            noIntenateView.isUserInteractionEnabled = true
        }
        else if imgeFlag == "5"{
            topOfbgView = 150
        }
        else if imgeFlag == "6"{
            imageName = UIImage(named: "sad_face")
        }
        
        let bgView = UIView(frame: CGRect(x:0, y:(noIntenateView.frame.size.width/2.0) - 100, width: screenSize.width, height:244))
       // bgView.backgroundColor = UIColor.clear
        // self.view.addSubview(noIntenateView)
        bgView.isUserInteractionEnabled = false
        noIntenateView.addSubview(bgView)
        
        bgView.center = CGPoint.init(x: noIntenateView.frame.size.width  / 2, y: (noIntenateView.frame.size.height / 2) - topOfbgView)
        
        
        /*/Image
        let imageView = UIImageView(image: imageName!)
        imageView.frame = CGRect.init(x: 140, y: 0, width: noIntenateView.frame.size.width - 280, height: 100)
        bgView.addSubview(imageView)
        imageView.contentMode = UIViewContentMode.scaleAspectFit*/
        
        //label for no Data
        let lblNew = UILabel()
        lblNew.numberOfLines = 2
        lblNew.lineBreakMode = .byWordWrapping
        lblNew.text = lableNoData
        lblNew.sizeToFit()
        lblNew.textColor = UIColor.white
        
        // bgView.center.y
        lblNew.frame = CGRect.init(x: 50, y: 0, width: noIntenateView.frame.size.width - 100, height: 30)
        lblNew.textAlignment = .center
        bgView.addSubview(lblNew)
        
        //label no internet
        let lblNew1 = UILabel()
        lblNew1.text = lableNoInternate
        
        //lblNew1.textColor = UIColor.darkGray
        lblNew1.textColor = UIColor.white
        
        lblNew1.frame = CGRect.init(x: 30, y: lblNew.frame.origin.y + lblNew.frame.size.height + 10, width: noIntenateView.frame.size.width - 60, height: 80)
        lblNew1.numberOfLines = 0
        lblNew1.textAlignment = .center
        bgView.addSubview(lblNew1)
        return noIntenateView
    }
}

extension String{
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat{
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
    
    func isStringAnInt() -> Bool {
        
        if let _ = Int(self) {
            return true
        }
        return false
    }
        
    func widthOfString(usingFont font: UIFont) -> CGFloat{
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    private static let decimalFormatter:NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        return formatter
    }()
    
    private var decimalSeparator:String{
        return String.decimalFormatter.decimalSeparator ?? "."
    }
    
    func isValidDecimal(maximumFractionDigits:Int)->Bool{
        
        // Depends on you if you consider empty string as valid number
        guard self.isEmpty == false else {
            return true
        }
        
        // Check if valid decimal
        if let _ = String.decimalFormatter.number(from: self){
            
            // Get fraction digits part using separator
            let numberComponents = self.components(separatedBy: decimalSeparator)
            let fractionDigits = numberComponents.count == 2 ? numberComponents.last ?? "" : ""
            return fractionDigits.count <= maximumFractionDigits
        }
        
        return false
    }
    mutating func until(_ string: String) {
        var components = self.components(separatedBy: string)
        self = components[0]
    }
    mutating func nxtUntil(_ string: String) {
        var components = self.components(separatedBy: string)
        self = components[1]
    }
    
    func isValidDecimalWithNumber(maximumFractionDigits:Int)->Bool{
        
        // Depends on you if you consider empty string as valid number
        guard self.isEmpty == false else {
            return true
        }
        
        // Check if valid decimal
        if let _ = String.decimalFormatter.number(from: self){
            
            // Get fraction digits part using separator
            let numberComponents = self.components(separatedBy: decimalSeparator)
            let fractionDigits = numberComponents.count == 9 ? numberComponents.first ?? "" : ""
            return fractionDigits.count <= maximumFractionDigits
        }
        
        return false
    }
    
}


extension NSMutableAttributedString{
    func widthOfString(usingFont font: UIFont) -> CGFloat{
        _ = [NSAttributedString.Key.font: font]
        let size = self.size()
        return size.width
    }
}

extension UIImageView{
    public func maskCircle(anyImage: UIImage){
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
    }
}



extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}

extension UIProgressView {
    @IBInspectable var barHeight : CGFloat {
        get {
            return transform.d * 2.0
        }
        set {
            // 2.0 Refers to the default height of 2
            let heightScale = newValue / 2.0
            let c = center
            //transform = CGAffineTransformMakeScale(1.0, heightScale)
            transform = CGAffineTransform(scaleX: 1.0, y: heightScale)
            center = c
        }
    }
}

extension UIView{
    func shake(){
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.values = [ 0, 10, -10, 10, 0 ]
        animation.keyTimes = [NSNumber(value: 0.0), NSNumber(value: 1.0 / 6.0), NSNumber(value: 3.0 / 6.0), NSNumber(value: 5.0 / 6.0), NSNumber(value: 1.0)]
        animation.duration = 0.4;
        animation.isAdditive = true
        
        layer.add(animation, forKey: "shake")
    }
}

extension Float{
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}

public extension LazyMapCollection{
    func toArray() -> [Element]{
        return Array(self)
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}


