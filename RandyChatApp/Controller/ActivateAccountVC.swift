//
//  ActivateAccountVC.swift
//  RandyChatApp
//
//  Created by Magneto on 09/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class ActivateAccountVC: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var txtSecureCode: SkyFloatingLabelTextField!
    @IBOutlet weak var lblInfoText: UILabel!
    @IBOutlet weak var btnActivateAccount: RoundedButton!
    
    var emailAddress = ""
    var successMessage:String?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationDesign()
        setNaviBackButton()
        self.title = "Activate Account"
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
        if txtSecureCode.text == "" {
            self.view.makeToast("Please enter the sucure code.")
        }else  {
            callActivateAccount()
        }
    }
    
    @IBAction func btnActivateClk(_ sender: Any) {
        validation()
    }
}

extension ActivateAccountVC {
    func callActivateAccount() {
        
        //http://sale24by7.com/randy_chat/public/index.php/api/activateAccount?userEmail=suvarnashinde.magneto@gmail.com&secureCode=y1v6Wi4w
        
        let secureCode = txtSecureCode.text
        
        let dictionary = [
                            "userEmail" : emailAddress,
                            "secureCode" : secureCode
                         ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "activateAccount?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfactivateAccount(strURL: strURL, dictionary: dictionary as! Dictionary<String, String> )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
}

//MARK: - WS Of Login
extension ActivateAccountVC {
    func callWSOfactivateAccount(strURL: String, dictionary:Dictionary<String,String>){
        
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["status"] as? String == "1"{
                let message = JSONResponse["message"] as! String
                self.view.makeToast(message)
                var foundLogin = false
                let login = self.storyboard?.instantiateViewController(withIdentifier :"LoginViewController") as! LoginViewController
                
                DispatchQueue.main.async {
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: LoginViewController.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            foundLogin = true
                            break
                        }
                    }
                    if !foundLogin {
                        self.navigationController?.pushViewController(login, animated: true)
                    }
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
