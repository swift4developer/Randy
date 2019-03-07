
//
//  MyChatVC.swift
//  RandyChatApp
//
//  Created by Magneto on 10/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase


class MyChatVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var tableViewMyChat: UITableView!
    @IBOutlet weak var btnNewChats: RoundedButton!
    
    var pageNumber = 1
    var resPgNumber = 0
    var remaining = 0
    var arrayChats = [chatList]()
    var refreshControl: UIRefreshControl!
    var flgActivity = true
    var apiSuccesFlag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myChatList()
        btnNewChats.isHidden = true
        refreshControl = UIRefreshControl()
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableViewMyChat.addSubview(refreshControl)
     }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func fetchallData() {
        let ref = Database.database().reference()
        for obj in arrayChats {
            
            if let id = obj.groupId {
                //        get all user data
                ref.child("Message").child(id).observe(.value) { (data) in
                    print(data.childrenCount)
                }
            }
        }
        
        
    }
    
    
    @objc func refresh(_ sender:AnyObject){
        flgActivity = false
        pageNumber = 1
        remaining = 0
        self.myChatList()
    }
    
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    
    func noDataLabel(str:String) {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableViewMyChat.bounds.size.width, height: tableViewMyChat.bounds.size.height))
        label.text = str
        label.textColor = color.themeDarkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        tableViewMyChat.backgroundView  = label
        tableViewMyChat.separatorStyle  = .none
    }
}

extension MyChatVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myChatCell", for: indexPath) as! myChatTableViewCell
        cell.lblUserName.text = arrayChats[indexPath.row].profileName
        cell.lblChatCount.text = "Chats \(arrayChats[indexPath.row].totalChatNumber ?? "0")"
        cell.lblTopicName.text = arrayChats[indexPath.row].discussionTitle
        cell.lblLastChatDate.text = "Last Chat: \(arrayChats[indexPath.row].lastChatTime ?? "Not Available")"
        //cell.lblNewMessageCount.text = arrayChats[indexPath.row].
        cell.profileImage.af_setImage(withURL: URL.init(string: arrayChats[indexPath.row].profileImage!)!)
        if arrayChats[indexPath.row].isActive == "1" {
            cell.imgOnlineStatus.isHidden = false
        }else {
            cell.imgOnlineStatus.isHidden = true
        }
        cell.lblNewMessageCount.isHidden = true
        return cell
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatDetails = self.storyboard?.instantiateViewController(withIdentifier: "MySelectChatView") as! MySelectChatView
        chatDetails.objChatList = arrayChats[indexPath.row]
        self.navigationController?.pushViewController(chatDetails, animated: true)
    }
}

extension MyChatVC {
    func myChatList() {
        
        let dictionary = [
            "userId" : userInfo.userID,
            "privateKey" : userInfo.privateKey,
            "pagenumber" : String(pageNumber),
            "limit" : "5"
        ]
        
        print("I/P:",dictionary)
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "myChatList?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            //startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            //self.callWSOfmyChatList(strURL: strURL, dictionary: dictionary )
            if flgActivity {
                startActivityIndicator()
                self.apiSuccesFlag = "1"
            }
            callAPI(strurl: strURL, params: dictionary)
        }else{
            self.view.makeToast(string.noInternetConnMsg)
            self.apiSuccesFlag = "2"
            self.stopActivityIndicator()
            self.refreshControl.endRefreshing()
        }
    }
}

//MARK: - WS Of Forgot
extension MyChatVC {
    
    func callAPI (strurl:String, params: [String:String]) {

        Alamofire.request(strurl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<MyChatModel>) in
            print(response)
            self.apiSuccesFlag = "2"
            self.stopActivityIndicator()
            self.refreshControl.endRefreshing()
            if response.result.isSuccess {
                let resJson = response.result.value
                if resJson != nil{
                    if resJson?.status == "1" {
                        if let remaing = resJson?.itemsremaining{
                            self.remaining = remaing;
                        }
                        if let nextPageNumber = resJson?.nextpagenumber{
                            self.resPgNumber = nextPageNumber
                        }
                        //self.arrayOfTopics.removeAll()
                        if let data = resJson?.chatList {
                            //self.arrayOfTopics = data
                            if(self.pageNumber == 1){
                                self.pageNumber =  self.pageNumber + 1;
                                self.arrayChats = data
                                self.fetchallData()
                                if self.arrayChats.count != 0{
                                    DispatchQueue.main.async{
                                        self.tableViewMyChat.reloadData()
                                    }
                                }
                            }
                            else{
                                self.pageNumber =  self.pageNumber + 1;
                                self.arrayChats =  self.arrayChats + data
                                if self.arrayChats.count != 0{
                                    DispatchQueue.main.async{
                                        self.tableViewMyChat.reloadData()
                                    }
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableViewMyChat.reloadData()
                        }
                    }else{
                        if let errorCode = resJson?.errorCode {
                            if errorCode == "99" {
                                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                                self.navigationController?.popToRootViewController(animated: true)
                            }else if errorCode == "100" {
                                self.noDataLabel(str: resJson?.message ?? "You have not chatted with anyone yet, please search for the topics.")
                            }else {
                                self.view.makeToast(resJson?.message ?? "Something went wrong.")
                            }
                        }else {
                            self.view.makeToast(resJson?.message ?? "Something went wrong.")
                        }
                    }
                }
            }
            if response.result.isFailure {
                let error : Error = response.result.error!
                print(error)
            }
        }
    }
}
