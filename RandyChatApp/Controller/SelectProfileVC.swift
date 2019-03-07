//
//  SelectProfileVC.swift
//  RandyChatApp
//
//  Created by Magneto on 09/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit

protocol  SelectProfileDelegate
{
    func didSelectProileImage(obj:ProfileModel) ->  Void
}

class SelectProfileVC: UIViewController, NVActivityIndicatorViewable {
    
    var delegate: SelectProfileDelegate!
    var profileImages = [ProfileModel]()
    var selectedProfile : ProfileModel?
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationDesign()
        setNaviBackButton()
        self.title = "Profile picture"
        getProfileImages()
    }
    
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    
    @IBAction func btnConfimClk(_ sender: Any) {
        self.delegate.didSelectProileImage(obj: selectedProfile!)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SelectProfileVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileImages.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! profileCollectionViewCell
        cell.profileImage.af_setImage(withURL: URL(string: profileImages[indexPath.row].imgUrl!)!, placeholderImage: UIImage(named: "profile-picture"), progress: { (progrss) in
            print("Image downloading - \(progrss.fractionCompleted)")
        }, progressQueue: DispatchQueue.main, runImageTransitionIfCached: true)
        cell.profileImage.backgroundColor = color.themeLightGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let cellWidth = self.profileCollectionView.frame.size.width/4
        //let cellHeight = self.profileCollectionView.frame.size.height
        let size = CGSize(width: 75.0, height: 75.0)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! profileCollectionViewCell
        cell.profileImage.backgroundColor = color.themeSkyBlue
        self.selectedProfile = profileImages[indexPath.row]
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! profileCollectionViewCell
        cell.profileImage.backgroundColor = color.themeLightGray
    }
}

//
extension SelectProfileVC {
    func getProfileImages() {
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "profileImages?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfgetProfileImages(strURL: strURL, dictionary: [:] )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
}


//MARK: - WS Of Login
extension SelectProfileVC {
    func callWSOfgetProfileImages(strURL: String, dictionary:Dictionary<String,String>){
        
        AFWrapper.requestGETURL(strURL, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["status"] as? String == "1"{
                let profileImages = JSONResponse["profileImages"] as! [[String:Any]]
                self.profileImages.removeAll()
                for profile in profileImages {
                    let id = profile["profileId"] as! String
                    let profileURL = profile["profileImage"] as! String
                    let profileObj = ProfileModel(id: id, imgUrl: profileURL)
                    self.profileImages.append(profileObj)
                }
                DispatchQueue.main.async {
                    self.profileCollectionView.reloadData()
                }
            }else{
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

class ProfileModel : NSObject {
    var id:String?
    var imgUrl:String?
    init(id:String,imgUrl:String) {
        self.id = id
        self.imgUrl = imgUrl
    }
}
