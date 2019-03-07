//
//  MyProfileVC.swift
//  RandyChatApp
//
//  Created by Magneto on 14/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit

class MyProfileVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var tblViewOfProfile: UITableView!
    
    var arrayOfProfile = ["My profile","Notification settings","Privacy policy","Terms and conditions","Contact us","Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblViewOfProfile.tableFooterView = UIView()
    }
   
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    
    func showAlert(title:String, message:String?) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
            self.userLogout()
        }))
        alert.addAction(UIAlertAction.init(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
extension MyProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfProfile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! myChatTableViewCell
        
        if indexPath.row == arrayOfProfile.count - 1 {
            cell.imgOfProfile.isHidden = true
        }else {
            cell.imgOfProfile.isHidden = false
            cell.imgOfProfile.image = UIImage(named: "next")
        }
        cell.lblOfProfileTitle.text = arrayOfProfile[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let profileDetail = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileDetailsVC") as! MyProfileDetailsVC
            self.navigationController?.pushViewController(profileDetail, animated: true)
        }else if indexPath.row == 1 {
            let profileDetail = self.storyboard?.instantiateViewController(withIdentifier: "NotificationSettingVC") as! NotificationSettingVC
            self.navigationController?.pushViewController(profileDetail, animated: true)
        }else if indexPath.row == 2 {
            let terms = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionVC") as! TermsAndConditionVC
            terms.camefrom = "Privacy"
            self.navigationController?.pushViewController(terms, animated: true)
        }else if indexPath.row == 3 {
            let terms = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionVC") as! TermsAndConditionVC
            terms.camefrom = "Terms"
            self.navigationController?.pushViewController(terms, animated: true)
        }else if indexPath.row == arrayOfProfile.count - 1 {
            showAlert(title: "Are you sure want to logout", message: nil)
        }
    }
}

extension MyProfileVC {
    
    //http://sale24by7.com/randy_chat_dev/public/index.php/api/userLogout?userId=1&privateKey=fRyLURg7AaJATSoK&logoutStatus=1
    func userLogout() {
        
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "logoutStatus" : "1"
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "userLogout?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfuserLogout(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
    
    func callWSOfuserLogout(strURL: String, dictionary:Dictionary<String,String>){
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    self.view.makeToast((JSONResponse["message"] as? String)!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        self.navigationController?.popToRootViewController(animated: true)
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
