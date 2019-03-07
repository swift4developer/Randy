//
//  SignUpViewController.swift
//  RandyChatApp
//
//  Created by Magneto on 08/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase

class SignUpViewController: UIViewController ,SelectProfileDelegate, NVActivityIndicatorViewable{
    
    func didSelectProileImage(obj: ProfileModel) {
        selectedImageData = obj
        self.imgProfile.af_setImage(withURL: URL(string: obj.imgUrl!)!)
        print(obj.imgUrl!)
    }
    
    @IBOutlet weak var imgChecked: UIImageView!
    @IBOutlet weak var lblTCnPP: UILabel!
    @IBOutlet weak var imagePassword: UIImageView!
    @IBOutlet weak var imageSubscription: UIImageView!
    @IBOutlet weak var btnSubscribe: UIButton!
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtDOB: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEmailAddress: SkyFloatingLabelTextField!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnAddProfile: UIButton!
    @IBOutlet weak var txtFullName: SkyFloatingLabelTextField!
    
    var selectProfileVc:SelectProfileVC!
    var subscribeStatus = "2"
    var selectedImageData: ProfileModel?
    var signUpData : Dictionary<String, Any> = [:]
    var loginType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgChecked.isHidden = true
        let tappedOnImage = UITapGestureRecognizer.init(target: self, action: #selector(tappedProfile))
        self.imgProfile.addGestureRecognizer(tappedOnImage)
        
        let tappedOnLabel = UITapGestureRecognizer.init(target: self, action: #selector(tapLabel))
        self.lblTCnPP.addGestureRecognizer(tappedOnLabel)
        
        if signUpData.count > 0 {
            txtFullName.text = signUpData["userName"] as? String
            txtEmailAddress.text = signUpData["userEmail"] as? String
            txtDOB.text = signUpData["birthDate"] as? String
            txtEmailAddress.isUserInteractionEnabled = false
        }else {
            txtEmailAddress.isUserInteractionEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationDesign()
        self.setNaviBackButton()
        self.title = "Sign up"
    }
    
    @objc func tappedProfile() {
        selectProfileVc = self.storyboard?.instantiateViewController(withIdentifier: "SelectProfileVC") as? SelectProfileVC
        selectProfileVc.delegate = self
        self.navigationController?.pushViewController(selectProfileVc, animated: true)
    }
    
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    
    func validation() {
        if txtFullName.text == "" {
            self.view.makeToast("Please enter full name.")
        }else if txtEmailAddress.text == "" {
            self.view.makeToast("Please enter email ID.")
        }else if Validation.isValidEmail(testEmail: txtEmailAddress.text!) {
            self.view.makeToast("Please enter valid email ID.")
        }else if txtDOB.text == "" {
            self.view.makeToast("Please enter date of birth.")
        }else if txtPassword.text == "" {
            self.view.makeToast("Please enter password.")
        }else if selectedImageData?.id == nil {
            self.view.makeToast("Please select profile picture first.")
        }else  {
            callRegisterAPI()
        }
    }
    
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        let text = (lblTCnPP.text)!
        let termsRange = (text as NSString).range(of: "Terms & Condition")
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionVC") as! TermsAndConditionVC
        if gesture.didTapAttributedTextInLabel(label: lblTCnPP, inRange: termsRange) {
            print("Tapped terms")
            vc.camefrom = "Terms"
        } else if gesture.didTapAttributedTextInLabel(label: lblTCnPP, inRange: privacyRange) {
            print("Tapped privacy")
            vc.camefrom = "Privacy"
        } else {
            print("Tapped none")
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func btnAddProfileClk(_ sender: Any) {
        
        selectProfileVc = self.storyboard?.instantiateViewController(withIdentifier: "SelectProfileVC") as? SelectProfileVC
        selectProfileVc.delegate = self
        self.navigationController?.pushViewController(selectProfileVc, animated: true)
        
    }
    @IBAction func btnSubcribeClk(_ sender: Any) {
        
        if imageSubscription.image == UIImage(named: "checkbox-disabled") {
            subscribeStatus = "1"
            imageSubscription.image = UIImage(named: "checkbox-enabled")
        }else {
            subscribeStatus = "2"
            imageSubscription.image = UIImage(named: "checkbox-disabled")
        }
    
    }
    
    @IBAction func btnGetstartedClk(_ sender: Any) {
        validation()
    }
   
    @IBAction func btnDOBClk(_ sender: Any) {
    }
    
    @IBAction func btnPasswordClk(_ sender: Any) {
        if imagePassword.image == UIImage.init(named: "eye-off") {
            txtPassword.isSecureTextEntry = false
            imagePassword.image = UIImage.init(named: "eye-on")
        }else {
            txtPassword.isSecureTextEntry = true
            imagePassword.image = UIImage.init(named: "eye-off")
        }
    }
    func didSelectProileImage(image: UIImage?) {
        if let image = image {
            self.imgProfile.image = image
            self.imgProfile.backgroundColor = color.themeLightGray
        }
    }
}

//MARK:- TextField Delegate Methods
extension SignUpViewController: UITextFieldDelegate {
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
        
        if !Validation.isValidEmail(testEmail: txtEmailAddress.text!) {
            self.imgChecked.isHidden = false
            return true
        }else {
            self.imgChecked.isHidden = true
            return true
        }
    }
}

extension SignUpViewController {
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

extension SignUpViewController {
    func callRegisterAPI() {
        
        var chatProfileID = ""
        if selectedImageData != nil {
            chatProfileID = (selectedImageData?.id)!
        }
        let email = txtEmailAddress.text!
        let name = txtFullName.text!
        let dob = txtDOB.text!
        let password = txtPassword.text!
        if signUpData.count > 0 {
            loginType = (signUpData["loginType"] as? String)!
        }else {
            loginType = "1"
        }
        let dictionary = [  "userEmail" : email,
                            "userName" : name,
                            "birthDate" : dob,
                            "userPassword" : password,
                            "chatProfileId" : "\(chatProfileID)",
                            "subscribeStatus" : subscribeStatus,
                            "loginType" : loginType]
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "userSignup?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfSignup(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
}


//MARK: - WS Of SignUP
extension SignUpViewController {
    func callWSOfSignup(strURL: String, dictionary:Dictionary<String,String>){
        
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            self.view.makeToast((JSONResponse["message"] as? String)!)
            
            if JSONResponse["status"] as? String == "1"{
                
                if self.loginType == "1" {
                    DispatchQueue.main.async {
                        let activateAccount = (self.storyboard?.instantiateViewController(withIdentifier: "ActivateAccountVC") as! ActivateAccountVC)
                        activateAccount.emailAddress = self.txtEmailAddress.text!
                        self.navigationController?.pushViewController(activateAccount, animated: true)
                    }
                }else {
                    DispatchQueue.main.async {
                        let myChat = self.storyboard?.instantiateViewController(withIdentifier: "MyTabBarVC") as! MyTabBarVC
                        myChat.successMessage = ((JSONResponse["message"] as? String)!)
                        self.navigationController?.pushViewController(myChat, animated: true)
                    }
                }
            }
            else if JSONResponse["status"] as? String == "0"{
                self.stopActivityIndicator()
                guard let emailStatus = JSONResponse["email_status"] as? String else { return }
                if emailStatus == "0" {
                    DispatchQueue.main.async {
                        let activateAccount = (self.storyboard?.instantiateViewController(withIdentifier: "ActivateAccountVC") as! ActivateAccountVC)
                        activateAccount.emailAddress = self.txtEmailAddress.text!
                        self.navigationController?.pushViewController(activateAccount, animated: true)
                    }
                }else {
                    self.view.makeToast((JSONResponse["message"] as? String)!)
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

