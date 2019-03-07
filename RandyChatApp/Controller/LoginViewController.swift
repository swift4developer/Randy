//
//  LoginViewController.swift
//  RandyChatApp
//
//  Created by Magneto on 08/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class LoginViewController: UIViewController,NVActivityIndicatorViewable, ForgotDelegate {
    
    @IBOutlet weak var imgRemember: UIImageView!
    @IBOutlet weak var btnShowPassword: UIButton!
    @IBOutlet weak var imgEmailChecked: UIImageView!
    @IBOutlet weak var txtEmailAddress: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var imgShowPassword: UIImageView!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnRememberMe: UIButton!
    
    var fbLoginManager = FBSDKLoginManager()
    var facebookUserId:String?
    var fullName = ""
    var dateOfBirth = ""
    var loginType = ""
    var deviceToken = ""
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.setNaviBackButton()
        self.title = "Log in"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signOut()
        self.imgEmailChecked.isHidden = true
        
        setupUI()
        getDeviceToken()
    }
    
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    
    //protocol
    func sendData(message: String?) {
        print(message!)
        self.view.makeToast(message!)
    }
    
    func getDeviceToken() {
        if appDelegate.instanceID == "" {
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instance ID: \(error)")
                } else if let result = result {
                    self.deviceToken = result.token
                    print("Remote instance ID token: \(result.token)")
                }
            }
        }else {
            deviceToken = appDelegate.instanceID
        }
    }
    
    func validation() {
        if txtEmailAddress.text == "" {
            self.view.makeToast("Please enter email ID.")
        }else if Validation.isValidEmail(testEmail: txtEmailAddress.text!) {
            self.view.makeToast("Please enter valid email ID.")
        }else if txtPassword.text == "" {
            self.view.makeToast("Please enter password.")
        }else  {
            callLoginAPI()
        }
    }
    
    func setupUI() {
        if (UserDefaults.standard.value(forKey: "rememberMe") as? Bool) != nil {
            let checked = UserDefaults.standard.value(forKey: "rememberMe") as! Bool
            if checked{
                imgRemember.image = UIImage.init(named: "checkbox-enabled")
                txtEmailAddress.text = UserDefaults.standard.value(forKey: "emailID") as? String
                txtPassword.text = UserDefaults.standard.value(forKey: "password") as? String
            }
        }else {
            imgRemember.image = UIImage.init(named: "checkbox-disabled")
            txtEmailAddress.text = ""
            txtPassword.text = ""
        }
    }
    
    func remeberPassword() {
        if imgRemember.image == UIImage(named: "checkbox-disabled") {
            imgRemember.image = UIImage(named: "checkbox-enabled")
            UserDefaults.standard.set(true, forKey: "rememberMe")
            UserDefaults.standard.set(txtEmailAddress.text, forKey: "emailID")
            UserDefaults.standard.set(txtPassword.text, forKey: "password")
        }else {
            imgRemember.image = UIImage(named: "checkbox-disabled")
            UserDefaults.standard.set(false, forKey: "rememberMe")
        }
    }
    
    
    @IBAction func btnFacebookClk(_ sender: Any) {
        loginType = "3"
        fbLoginManager.loginBehavior = .native
        fbLoginManager.logOut()
        if(FBSDKAccessToken.current() != nil) {
            self.returnFacebookAccessTokenWithLogin()
        } else {
            fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
                if (error == nil){
                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
                    // if user cancel the login
                    if (result?.isCancelled)!{
                        return
                    }
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.returnFacebookAccessTokenWithLogin()
                    }
                }
            }
        }
    }
    
    @IBAction func btnGoogleClk(_ sender: Any) {
        loginType = "2" //Google sign in
        GIDSignIn.sharedInstance().signOut()//Remove this line when u signout from ur app
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func btnSignUpClk(_ sender: Any) {
        loginType = "1" //normal sign in
        validation()
        
    }
    @IBAction func btnShowPasswordClk(_ sender: Any) {
        if imgShowPassword.image == UIImage.init(named: "eye-off") {
            txtPassword.isSecureTextEntry = false
            imgShowPassword.image = UIImage.init(named: "eye-on")
        }else {
            txtPassword.isSecureTextEntry = true
            imgShowPassword.image = UIImage.init(named: "eye-off")
        }
    }
    @IBAction func btnRememberClk(_ sender: Any) {
        remeberPassword()
    }
    @IBAction func btnForgotClk(_ sender: Any) {
        let vcOBJ = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        vcOBJ.forgotDelegate = self
        self.navigationController?.pushViewController(vcOBJ, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !Validation.isValidEmail(testEmail: txtEmailAddress.text!) {
            self.imgEmailChecked.isHidden = false
            return true
        }else {
            self.imgEmailChecked.isHidden = true
            return true
        }
    }
    
    /*func textFieldDidEndEditing(_ textField: UITextField) {
     if imgRemember.image == UIImage(named: "checkbox-disabled") {
     UserDefaults.standard.set(true, forKey: "rememberMe")
     UserDefaults.standard.set(txtEmailAddress.text, forKey: "emailID")
     UserDefaults.standard.set(txtPassword.text, forKey: "password")
     }else {
     UserDefaults.standard.set(false, forKey: "rememberMe")
     }
     }*/
}

extension LoginViewController {
    func callLoginAPI() {
        
        let emailAddress = txtEmailAddress.text
        let password = txtPassword.text
        let dictionary = ["loginType" : loginType, //1 = Normal, 2 = Gplus, 3 = Fb
            "password" : password,
            "deviceId" : deviceToken,
            "userEmail" : emailAddress
            ] as! [String : String]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "userLogin?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfLogin(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
}

//MARK:- Google Sign in
extension LoginViewController : GIDSignInUIDelegate,GIDSignInDelegate {
    // pressed the Sign In button
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
        print("Sign in present")
    }
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            let userId = user.userID                  // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            self.fullName = user.profile.name
            let email = user.profile.email
            let emailAddress = (email)!
            let password = ""
            let deviceID = appDelegate.instanceID
            let gplusTokenId = String(userId!)
            
            let dictionary = ["userEmail" : emailAddress,
                              "password" : password,
                              "deviceId" : deviceID,
                              "gplusTokenId" : gplusTokenId,
                              "birthDate" : "",
                              "userName" : fullName,
                              "loginType" : loginType
            ]
            print("I/P: ",dictionary)
            var strURL = ""
            strURL = String(strURL.dropFirst(1))
            strURL = Url.baseURL + "userLogin?"
            print(strURL)
            strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            
            if Validation.isConnectedToNetwork() == true {
                self.startActivityIndicator()
                _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
                self.callWSOfLogin(strURL: strURL, dictionary: dictionary)
            }else{
                self.view.makeToast(string.noInternetConnMsg)
            }
        } else{
            print("\(error.localizedDescription)")
        }
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
        print("Sign in dismiss ")
        GIDSignIn.sharedInstance().signOut()
    }
}

//MARK:- Facebook API Call
extension LoginViewController {
    
    @objc func returnFacebookAccessTokenWithLogin() {
        let ACCESS_TOKEN = FBSDKAccessToken.current().tokenString
        print(ACCESS_TOKEN!)
        if let UserID = FBSDKAccessToken.current()?.userID {
            facebookUserId = UserID
        }
        let appID = FBSDKAccessToken.current().appID
        print(appID ?? "")
        returnUserData()
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters:["fields":"name,email,first_name,last_name,birthday"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil) {
                print(error.debugDescription)
            } else {
                let dict = result as! [String : Any]
                let fbTokenId = (dict["id"] as? String) ?? ""
                let userEmail = (dict["email"] as? String) ?? ""
                if (dict["birthday"] as? String) != nil {
                    self.dateOfBirth = (dict["birthday"] as? String) ?? ""
                }
                self.fullName = "\((dict["first_name"] as? String) ?? "") \((dict["last_name"] as? String) ?? "")"
                let password = ""
                let dictionary = ["userEmail" : userEmail,
                                  "password" : password,
                                  "deviceId" : self.deviceToken,
                                  "fbTokenId" : fbTokenId,
                                  "birthDate" : self.dateOfBirth,
                                  "userName" : self.fullName,
                                  "loginType" : self.loginType
                ]
                print("I/P: ",dictionary)
                var strURL = ""
                strURL = String(strURL.dropFirst(1))
                strURL = Url.baseURL + "userLogin?"
                print(strURL)
                strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                
                if Validation.isConnectedToNetwork() == true {
                    self.startActivityIndicator()
                    _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
                    self.callWSOfLogin(strURL: strURL, dictionary: dictionary)
                }else{
                    self.view.makeToast(string.noInternetConnMsg)
                }
            }
        })
    }
}


//MARK: - WS Of Login
extension LoginViewController {
    func callWSOfLogin(strURL: String, dictionary:Dictionary<String,String>){
        
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["status"] as? String == "1"{
                
                //guard let message = JSONResponse["message"] as? String else {return}
                
                guard let emailAddress = JSONResponse["emailId"] as? String else {return}
                
                guard let user_id = JSONResponse["userid"] as? String else { return}
                guard let private_Key = JSONResponse["privatekey"] as? String else{ return}
                
                userInfo.userID = user_id
                userInfo.privateKey = private_Key
                UserDefaults.standard.set(user_id, forKey: "userid")
                UserDefaults.standard.set(private_Key, forKey: "privatekey")
                
                if let profileFlag = JSONResponse["profileFlag"] as? String  {
                    if profileFlag == "0" { //not set any profile avtar
                        DispatchQueue.main.async {
                            let profile = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
                            
                            profile.signUpData = ["userEmail" : emailAddress,
                                                  "birthDate" : self.dateOfBirth,
                                                  "userName" : self.fullName,
                                                  "loginType" : self.loginType]
                            self.navigationController?.pushViewController(profile, animated: true)
                        }
                    }else {
                        DispatchQueue.main.async {
                            
                            var dict = [String:String]()
                            dict["userId"] = user_id
                            dict["email"] = emailAddress
                            
                            UserDefaults.standard.set(dict, forKey: UserPreference.UserDetails)
                            UserDefaults.standard.synchronize()
                            
                            self.FirebaseSignUp()
                            
                            
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        
                        var dict = [String:String]()
                        dict["userId"] = user_id
                        dict["email"] = emailAddress
                        
                        UserDefaults.standard.set(dict, forKey: UserPreference.UserDetails)
                        UserDefaults.standard.synchronize()
                        
                        self.FirebaseSignUp()
                        
                        //                        let myChat = self.storyboard?.instantiateViewController(withIdentifier: "MyTabBarVC") as! MyTabBarVC
                        //                        myChat.successMessage = message
                        //                        self.navigationController?.pushViewController(myChat, animated: true)
                    }
                }
            }else{
                self.stopActivityIndicator()
                guard let message = JSONResponse["message"] as? String else {return}
                self.view.makeToast(message)
                if let emailstatus = JSONResponse["emailstatus"] as? String {
                    if emailstatus == "0" {
                        DispatchQueue.main.async {
                            let myChat = self.storyboard?.instantiateViewController(withIdentifier: "ActivateAccountVC") as! ActivateAccountVC
                            myChat.successMessage = message
                            myChat.emailAddress = self.txtEmailAddress.text!
                            self.navigationController?.pushViewController(myChat, animated: true)
                        }
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
    
    
    func FirebaseSignUp() {
        
        Auth.auth().createUser(withEmail: txtEmailAddress.text!,
                               password: txtPassword.text!)
        { user, error in
            if error == nil {
                Auth.auth().signIn(withEmail: self.txtEmailAddress.text!, password: self.txtPassword.text!, completion: {
                    user, error in
                    if error != nil {
                        print("Error")
                    } else {
                        let databaseRef = Database.database().reference()
                        let uid = Auth.auth().currentUser?.uid
                        
                        databaseRef.setValue(["uid": uid, "email": self.txtEmailAddress.text!, "login": self.txtPassword.text!, "creationDate": String(describing: Date())])
                        
                        
                        databaseRef.child("Message").child(uid!).observe(.value, with: {
                            snapshot in
                            if snapshot.childrenCount == 0 {
                                print("No child available")
                            } else {
                                print("We got some data")
                            }
                        })
                        
                        if uid != nil {
                            let myChat = self.storyboard?.instantiateViewController(withIdentifier: "MyTabBarVC") as! MyTabBarVC
                            self.navigationController?.pushViewController(myChat, animated: true)
                        }
                        
                    }
                })
            } else {
                
                try! Auth.auth().signOut()
                
                Auth.auth().signIn(withEmail: self.txtEmailAddress.text!, password: self.txtPassword.text!, completion: {
                    
                    user, error in
                    
                    if error != nil {
                        print("Error")
                    } else {
                        
                        let uid = Auth.auth().currentUser?.uid
                        if uid != nil {
                            let myChat = self.storyboard?.instantiateViewController(withIdentifier: "MyTabBarVC") as! MyTabBarVC
                            self.navigationController?.pushViewController(myChat, animated: true)
                        }
                    }
                    
                })
                print("\(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    
}

