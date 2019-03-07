//
//  ForgotPasswordVC.swift
//  RandyChatApp
//
//  Created by Magneto on 09/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

protocol ForgotDelegate {
    func sendData(message:String?)
}

class ForgotPasswordVC: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var imgChecked: UIImageView!
    @IBOutlet weak var lblInfoText: UILabel!
    @IBOutlet weak var txtEmailAddress: SkyFloatingLabelTextField!
    @IBOutlet weak var btnResetPassword: RoundedButton!
    
    var forgotDelegate: ForgotDelegate?
    var successMessage : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgChecked.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationDesign()
        setNaviBackButton()
        self.title = "Forgot Password"
        if successMessage != nil {
            self.view.makeToast(successMessage!)
        }
    }
    
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    
    func validation() {
        if txtEmailAddress.text == "" {
            self.view.makeToast("Please enter email ID.")
        }else if Validation.isValidEmail(testEmail: txtEmailAddress.text!) {
            self.view.makeToast("Please enter valid email ID.")
        }else {
            callActivateAccount()
        }
    }
    
    @IBAction func btnResetClk(_ sender: Any) {
        validation()
    }
   
}


//MARK:- TextField Delegate Methods
extension ForgotPasswordVC: UITextFieldDelegate {
    
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

extension ForgotPasswordVC {
    func callActivateAccount() {
        
        let emailAddress = txtEmailAddress.text
        
        let dictionary = [
                            "userEmail" : emailAddress,
                         ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "forgotPassword?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfForgotPassword(strURL: strURL, dictionary: dictionary as! Dictionary<String, String> )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
}

//MARK: - WS Of Forgot
extension ForgotPasswordVC {
    func callWSOfForgotPassword(strURL: String, dictionary:Dictionary<String,String>){
        
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["status"] as? String == "1"{
                self.successMessage = JSONResponse["message"] as? String
                if self.forgotDelegate != nil {
                    self.forgotDelegate?.sendData(message: self.successMessage!)
                }
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else{
                self.stopActivityIndicator()
                self.view.makeToast((JSONResponse["message"] as? String)!)
                
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
