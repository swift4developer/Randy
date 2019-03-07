
//
//  MyProfileDetailsVC.swift
//  RandyChatApp
//
//  Created by Magneto on 15/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import ObjectMapper

class MyProfileDetailsVC: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var topProfileView: viewOfShadow!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var lblOfEmail: UILabel!
    @IBOutlet weak var tblviewOfTopics: UITableView!
    @IBOutlet weak var lblOfJoiningDate: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var profileImage: RoundedImageView!
    @IBOutlet weak var viewForTable: UIView!
    
    var arrayOfTopics = [[String:Any]]()
    var selectedTopicID = ""
    var pageNumber = 1
    var resPgNumber = 0
    var remaining = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationDesign()
        self.setNaviBackButton()
        self.title = "My profile"
        tblviewOfTopics.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pageNumber = 1
        myProfile()
    }
    
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    
    @objc func removeClk(_ sender : UIButton?){
        
        //let section = (sender?.tag)! / 1000
        let row = (sender?.tag)! % 1000
        
        let currentDic = self.arrayOfTopics[row]
        let topicId = currentDic["topicId"] as! String
        pageNumber = 1
        self.removeFavTopic(id: topicId)
    }
    
    @IBAction func btnEditProfileClk(_ sender: Any) {
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "PersonalinfoVC") as! PersonalinfoVC
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
}

extension MyProfileDetailsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileTopicsCell", for: indexPath) as! myChatTableViewCell
        let dict = arrayOfTopics[indexPath.row]
        cell.lblOfFavTopics.text = dict["topicName"] as? String
        
        cell.btnDeleteFavTopic.tag = indexPath.section*1000 + indexPath.row;
        cell.btnDeleteFavTopic.addTarget(self, action: #selector(removeClk(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = arrayOfTopics[indexPath.row]
        selectedTopicID = dict["topicId"] as! String
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if(indexPath.row == self.arrayOfTopics.count-1){
            if(self.pageNumber <= self.resPgNumber){
                if(remaining > 0){
                    let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
                    spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                    spinner.startAnimating()
                    tableView.tableFooterView = spinner
                    tableView.tableFooterView?.isHidden = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.myProfile()                  }
                }
                else{
                    tableView.tableFooterView?.removeFromSuperview()
                    let view = UIView()
                    view.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(5))
                    tableView.tableFooterView = view
                    tableView.tableFooterView?.isHidden = true
                }
            }
            else{
                tableView.tableFooterView?.removeFromSuperview()
                let view = UIView()
                view.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(5))
                tableView.tableFooterView = view
                tableView.tableFooterView?.isHidden = true
            }
        }else{
            tableView.tableFooterView?.removeFromSuperview()
            let view = UIView()
            view.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(5))
            tableView.tableFooterView = view
            tableView.tableFooterView?.isHidden = true
        }
}
}

extension MyProfileDetailsVC {
    func myProfile() {
        
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "pagenumber": String(pageNumber),
            "limit" : "5"
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "myProfile?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfmyProfile(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
    
    func removeFavTopic(id:String) {
        
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "favTopicId": id
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "removeFavTopic?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfremoveFavTopic(strURL: strURL, dictionary: dictionary )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
}

//MARK: - WS Of Forgot
extension MyProfileDetailsVC {
    func callWSOfmyProfile(strURL: String, dictionary:Dictionary<String,String>){
        
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    if let remaing = JSONResponse["itemsremaining"] as? Int{
                        self.remaining = remaing;
                    }
                    if let nextPageNumber = (JSONResponse["nextpagenumber"] as? Int){
                        self.resPgNumber = nextPageNumber
                    }
                    //self.arrayOfTopics.removeAll()
                    if let data = JSONResponse["faviourateTopics"] as? [[String:Any]] {
                        //self.arrayOfTopics = data
                        if(self.pageNumber == 1){
                            self.pageNumber =  self.pageNumber + 1;
                            self.arrayOfTopics = data
                            if self.arrayOfTopics.count != 0{
                                DispatchQueue.main.async{
                                    self.tblviewOfTopics.reloadData()
                                }
                            }
                        }
                        else{
                            self.pageNumber =  self.pageNumber + 1;
                            self.arrayOfTopics =  self.arrayOfTopics + data
                            if self.arrayOfTopics.count != 0{
                                DispatchQueue.main.async{
                                    self.tblviewOfTopics.reloadData()
                                }
                            }
                        }
                    }
                    if let userName = JSONResponse["userName"] as? String{
                        self.lblUserName.text = userName
                    }
                    if let userEmail = JSONResponse["userEmail"] as? String{
                        self.lblOfEmail.text = userEmail
                    }
                    if let joinedDate = JSONResponse["joinedDate"] as? String{
                        self.lblOfJoiningDate.text = "Joined: \(joinedDate)"
                    }
                    if let profileImage = JSONResponse["profileImage"] as? String {
                        self.profileImage.af_setImage(withURL: URL.init(string: profileImage)!)
                    }
                    DispatchQueue.main.async {
                        self.tblviewOfTopics.reloadData()
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
    
    
    func callWSOfremoveFavTopic(strURL: String, dictionary:Dictionary<String,String>){
        
        let img = UIImage()
        AFWrapper.requestPostURLForUploadImage(strURL, isImageSelect: false, fileName: "", params: dictionary as [String : AnyObject], image: img, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["Error"] as? String == "API Crashed" {
                self.view.makeToast(string.someThingWrongMsg)
            }else {
                if JSONResponse["status"] as? String == "1"{
                    self.view.makeToast((JSONResponse["message"] as? String)!)
                    DispatchQueue.main.async {
                        self.myProfile()
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
}

