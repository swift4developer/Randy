//
//  ChangePasswordVC.swift
//  RandyChatApp
//
//  Created by Magneto on 17/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class ChangePasswordVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var btnResetPassword: RoundedButton!
    @IBOutlet weak var txtConfirmPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtNewPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtOldPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var viewOfPassword: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func validation() {
        if txtOldPassword.text == "" {
            self.view.makeToast("Please enter old password.")
        }else if txtNewPassword.text == "" {
            self.view.makeToast("Please enter new password.")
        }else if txtConfirmPassword.text == "" {
            self.view.makeToast("Please enter confirm password.")
        }else if txtNewPassword.text != txtConfirmPassword.text {
            self.view.makeToast("Enter password is not matching.")
        }else  {
            changePassword()
        }
    }
    
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationDesign()
        setNaviBackButton()
        self.title = "Change Password"
    }
    @IBAction func btnPasswordClk(_ sender: Any) {
        validation()
    }
}

extension ChangePasswordVC {
    func changePassword() {
        
        let old = txtOldPassword.text!
        let new  = txtNewPassword.text!
        let confirm = txtConfirmPassword.text!
        
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "oldPassword" : old,
            "newPassword" : new,
            "confirmPassword": confirm
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "changePassword?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfchangePassword(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
    
    func callWSOfchangePassword(strURL: String, dictionary:Dictionary<String,String>){
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    self.view.makeToast((JSONResponse["message"] as? String)!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.25, execute: {
                        self.navigationController?.popViewController(animated: true)
                    })
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
