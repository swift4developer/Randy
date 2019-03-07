//
//  PersonalinfoVC.swift
//  RandyChatApp
//
//  Created by Magneto on 15/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class PersonalinfoVC: UIViewController,NVActivityIndicatorViewable,SelectProfileDelegate {
    
    @IBOutlet weak var txtEmailAddress: SkyFloatingLabelTextField!
    @IBOutlet weak var imgUserProfile: RoundedImageView!
    @IBOutlet weak var imgSubscription: UIImageView!
    @IBOutlet weak var txtMobile: SkyFloatingLabelTextField!
    @IBOutlet weak var txtDOB: SkyFloatingLabelTextField!
    @IBOutlet weak var btnDOB: UIButton!
    @IBOutlet weak var txtFirstName: SkyFloatingLabelTextField!
    @IBOutlet weak var imgPasswordEye: UIImageView!
    @IBOutlet weak var btnChangeProfile: UIButton!
    @IBOutlet weak var imgChecked: UIImageView!
    
    var selectedImageData: ProfileModel?
    var subscribeStatus = "2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        personalInfo()
        txtDOB.delegate = self
        txtMobile.delegate = self
        txtEmailAddress.isUserInteractionEnabled = false
        self.imgChecked.isHidden = true
        let tappedOnImage = UITapGestureRecognizer.init(target: self, action: #selector(tappedProfile))
        self.imgUserProfile.addGestureRecognizer(tappedOnImage)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationDesign()
        self.setNaviBackButton()
        self.title = "Personal info"
       
    }
    func validation() {
        if txtFirstName.text == "" {
            self.view.makeToast("Please enter full name.")
        }else if txtEmailAddress.text == "" {
            self.view.makeToast("Please enter email ID.")
        }else if Validation.isValidEmail(testEmail: txtEmailAddress.text!) {
            self.view.makeToast("Please enter valid email ID.")
        }else if txtDOB.text == "" {
            self.view.makeToast("Please enter date of birth.")
        }else if txtMobile.text == "" {
            self.view.makeToast("Please enter mobile number.")
        }
//        else if selectedImageData?.id == nil {
//            self.view.makeToast("Please select profile picture first.")
//        }
        else  {
            updateProfile()
        }
    }
    @objc func tappedProfile() {
        let selectProfileVc = self.storyboard?.instantiateViewController(withIdentifier: "SelectProfileVC") as? SelectProfileVC
        selectProfileVc!.delegate = self
        self.navigationController?.pushViewController(selectProfileVc!, animated: true)
    }
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    func didSelectProileImage(obj: ProfileModel) {
        selectedImageData = obj
        self.imgUserProfile.af_setImage(withURL: URL(string: obj.imgUrl!)!)
        print(obj.imgUrl!)
    }
    
    @IBAction func btnChangeProfileClk(_ sender: Any) {
        let selectProfileVc = self.storyboard?.instantiateViewController(withIdentifier: "SelectProfileVC") as? SelectProfileVC
        selectProfileVc!.delegate = self
        self.navigationController?.pushViewController(selectProfileVc!, animated: true)
    }
    @IBAction func btnDOBclk(_ sender: Any) {
    }
    @IBAction func btnSubscriptionClk(_ sender: Any) {
        if imgSubscription.image == UIImage(named: "checkbox-disabled") {
            subscribeStatus = "1"
            imgSubscription.image = UIImage(named: "checkbox-enabled")
        }else {
            subscribeStatus = "2"
            imgSubscription.image = UIImage(named: "checkbox-disabled")
        }
    }
    @IBAction func btnUpdateProfileClk(_ sender: Any) {
        validation()
    }
    @IBAction func btnChangePassword(_ sender: Any) {
        let changePassword = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        self.navigationController?.pushViewController(changePassword, animated: true)
    }
    
}


//MARK:- TextField Delegate Methods
extension PersonalinfoVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtDOB{
            
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = UIDatePicker.Mode.date
            
            var components = DateComponents()
            components.year = -100
            //let minDate = Calendar.current.date(byAdding: components, to: Date())
            let maxDate = Date()
            //datePickerView.minimumDate = minDate
            datePickerView.maximumDate = maxDate
            textField.inputView = datePickerView
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            if txtDOB.text! != "" {
                let selectedDate = dateFormatter.date(from: txtDOB.text!)
                datePickerView.date = selectedDate!
            }
            datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
            crateToolBar()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtEmailAddress {
            if !Validation.isValidEmail(testEmail: txtEmailAddress.text!) {
                self.imgChecked.isHidden = false
                return true
            }else {
                self.imgChecked.isHidden = true
                return true
            }
        }else if textField == txtMobile {
            let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return checkEnglishPhoneNumberFormat(string: string, str: str)
        }else {
            return true
        }
    }
    
    func checkEnglishPhoneNumberFormat(string: String?, str: String?) -> Bool{
        
        if string == ""{ //BackSpace
            return true
        }
//        else if str!.count < 3{
//            if str!.count == 1{
//                txtMobile.text = "+1 "
//            }
//        }
        else if str!.count == 4{
            txtMobile.text = txtMobile.text! + "-"
        }else if str!.count == 8{
            txtMobile.text = txtMobile.text! + "-"
        }
        else if str!.count > 12{
            return false
        }
        return true
    }
    
    func crateToolBar(){
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.white
        //toolBar.backgroundColor = color.barTintColor
        toolBar.backgroundColor = UIColor.lightGray
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        label.font = UIFont(name: "Helvetica-Light", size: 12)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.text = "Select Date of birth"
        label.textAlignment = NSTextAlignment.center
        
        toolBar.setItems([flexSpace,doneButton], animated: true)
        txtDOB.inputAccessoryView = toolBar
    }
    
    @objc func donePressed(_ sender: UIBarButtonItem){
        txtDOB.resignFirstResponder()
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = tempLocale // reset the locale
        txtDOB.text = dateFormatter.string(from: sender.date)
    }
}


extension PersonalinfoVC {
    func personalInfo() {
        let dictionary = [
                            "userId" : userInfo.userID,
                            "privateKey" : userInfo.privateKey
                         ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "personalInfo?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfpersonalInfo(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
    
    func updateProfile() {
        
        let name = txtFirstName.text!
        let birthDate = txtDOB.text!
        let userPhone = txtMobile.text!
        var chatProfileID = ""
        if selectedImageData != nil {
            chatProfileID = (selectedImageData?.id)!
        }
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "userName": name,
            "chatProfileId" :chatProfileID,
            "birthDate": birthDate,
            "subscribeStatus": subscribeStatus,
            "userPhone":userPhone
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "updateProfile?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfupdateProfile(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
}

//MARK: - WS Of Forgot
extension PersonalinfoVC {
    func callWSOfpersonalInfo(strURL: String, dictionary:Dictionary<String,String>){
        
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    if let userName = JSONResponse["userName"] as? String{
                        self.txtFirstName.text = userName;
                    }
                    if let userEmail = (JSONResponse["userEmail"] as? String){
                        self.txtEmailAddress.text = userEmail
                    }
                    if let chatImage = JSONResponse["chatImage"] as? String{
                        self.imgUserProfile.af_setImage(withURL: URL.init(string: chatImage)!)
                    }
                    if let dateOfBirth = JSONResponse["dateOfBirth"] as? String{
                        self.txtDOB.text = dateOfBirth
                    }
                    if let userEmail = JSONResponse["userPhone"] as? String{
                        self.txtMobile.text = userEmail
                    }
                    if let subscribeStatus = JSONResponse["subscribeStatus"] as? String{
                        if subscribeStatus == "1" {
                            self.imgSubscription.image = UIImage(named: "checkbox-enabled")
                        }else {
                            self.imgSubscription.image = UIImage(named: "checkbox-disabled")
                        }
                    }
                }else{
                    if let errorCode = JSONResponse["errorCode"] as? String {
                        if errorCode == "99" {
                            UserDefaults.standard.set(false, forKey: "isLoggedIn")
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }else {
                        self.view.makeToast((JSONResponse["message"] as? String)!)
                    }
                }
            }
        }, failure: { (error) in
            print("error: ",error)
            DispatchQueue.main.async{
                self.view.makeToast(string.someThingWrongMsg)
                self.stopActivityIndicator()
            }
        })
    }
    
    func callWSOfupdateProfile(strURL: String, dictionary:Dictionary<String,String>){
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    self.view.makeToast((JSONResponse["message"] as? String)!)
                }else{
                    if let errorCode = JSONResponse["errorCode"] as? String {
                        if errorCode == "99" {
                            UserDefaults.standard.set(false, forKey: "isLoggedIn")
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }else {
                        self.view.makeToast((JSONResponse["message"] as? String)!)
                    }
                }
            }
        }, failure: { (error) in
            print("error: ",error)
            DispatchQueue.main.async{
                self.view.makeToast(string.someThingWrongMsg)
                self.stopActivityIndicator()
            }
        })
    }
}

