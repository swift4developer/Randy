//
//  NotificationSettingVC.swift
//  RandyChatApp
//
//  Created by Magneto on 17/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit

class NotificationSettingVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var tblViewNotificationList: UITableView!
    
    var notificationArray = [[String:Any]]()
    var notificationFlag = ""
    var offlineFlag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotificationSetting()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationDesign()
        self.setNaviBackButton()
        self.title = "Notification settings"
        self.tblViewNotificationList.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.setNotificationSetting()
    }
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
}

extension NotificationSettingVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! myChatTableViewCell
        let dataDictionary = notificationArray[indexPath.row]
        cell.lblOfnotificationTitle.text = (dataDictionary["name"] as! String)
        let notification = (dataDictionary["status"] as! String)
        if notification == "1" {
            cell.btnSwitch.setImage(UIImage.init(named: "toggle-enabled"), for: .normal)
        }else {
            cell.btnSwitch.setImage(UIImage.init(named: "toggle-disabled"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! myChatTableViewCell
        if cell.btnSwitch.currentImage == UIImage.init(named: "toggle-enabled") {
            cell.btnSwitch.setImage(UIImage.init(named: "toggle-disabled"), for: .normal)
            if indexPath.row == 0 {
                notificationFlag = "2"
            }else if indexPath.row == 1{
                offlineFlag = "2"
            }
        }else {
            cell.btnSwitch.setImage(UIImage.init(named: "toggle-enabled"), for: .normal)
            if indexPath.row == 0 {
                notificationFlag = "1"
            }else if indexPath.row == 1{
                offlineFlag = "1"
            }
        }
    }
}

extension NotificationSettingVC {
    func getNotificationSetting() {
        
        let dictionary = [
                            "userId" : userInfo.userID,
                            "privateKey" : userInfo.privateKey
                         ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "getNotificationSetting?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfgetNotificationSetting(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
    
    //http://sale24by7.com/randy_chat_dev/public/index.php/api/setNotificationSetting?userId=1&privateKey=fRyLURg7AaJATSoK&notificationFlag=1&offlineFlag=2
    func setNotificationSetting() {
        
        let dictionary = [
                            "userId" : userInfo.userID,
                            "privateKey" : userInfo.privateKey,
                            "notificationFlag" : notificationFlag,
                            "offlineFlag" : offlineFlag
                         ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "setNotificationSetting?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfsetNotificationSetting(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
}

//MARK: - WS Of Notification
extension NotificationSettingVC {
    func callWSOfgetNotificationSetting(strURL: String, dictionary:Dictionary<String,String>){
        
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    self.notificationArray.removeAll()
                    if let data = JSONResponse["data"] as? [[String:Any]] {
                        self.notificationArray = data
                        self.notificationFlag = data[0]["status"] as! String
                        self.offlineFlag = data[1]["status"] as! String
                    }
                    DispatchQueue.main.async {
                        self.tblViewNotificationList.reloadData()
                    }
                }else{
                    self.stopActivityIndicator()
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
    
    func callWSOfsetNotificationSetting(strURL: String, dictionary:Dictionary<String,String>){
        
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

