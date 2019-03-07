//
//  TermsAndConditionVC.swift
//  RandyChatApp
//
//  Created by Magneto on 17/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit
import WebKit

class TermsAndConditionVC: UIViewController, WKUIDelegate, WKNavigationDelegate,NVActivityIndicatorViewable {

    var webview: WKWebView?
    var camefrom: String?
    var baseURL : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationDesign()
        self.setNaviBackButton()
        
        getTermsUrl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if camefrom != "" {
            if camefrom == "Privacy" {
                self.title = "Privacy policy"
            }else if camefrom == "Terms" {
                self.title = "Terms & conditions"
            }else {
                self.title = "No Title"
            }
        }
        createWebView()
    }
    
    func startActivityIndicator() {
        let size = CGSize(width: 50, height: 50)
        startAnimating(size, type: NVActivityIndicatorType?.init(.semiCircleSpin), color: color.themeSkyBlue)
    }
    
    func stopActivityIndicator() {
        self.stopAnimating()
    }
    
    func createWebView() {
        let webViewConfiguration1 = WKWebViewConfiguration()
        webview = WKWebView(frame: .zero, configuration: webViewConfiguration1)
        //webview?.scrollView.delegate = self
        webview?.translatesAutoresizingMaskIntoConstraints = false
        webview?.scrollView.backgroundColor = UIColor.clear
        webview?.backgroundColor = UIColor.clear
        webview?.isOpaque = false
        webview?.uiDelegate = self
        webview?.navigationDelegate = self
        self.view.addSubview(webview!)
        
        if #available(iOS 11.0, *) {
            webview?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        } else {
            // Fallback on earlier versions
            webview?.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        }
        webview?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webview?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webview?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        webview?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        webview?.scrollView.isScrollEnabled = true
        webview?.scrollView.bounces = true
        webview?.sizeToFit()
        
    }
    
    func loadWebView (url:String) {
        webview?.load(URLRequest.init(url: URL.init(string: url)!))
    }
}

extension TermsAndConditionVC {
    func getTermsUrl() {
        
        var strURL = ""
        strURL = String(strURL.dropFirst(1))
        strURL = Url.baseURL + "getTermsUrl?"
        print(strURL)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        if Validation.isConnectedToNetwork() == true {
            startActivityIndicator()
            _ = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            self.callWSOfgetTermsUrl(strURL: strURL )
        }else{
            self.view.makeToast(string.noInternetConnMsg)
        }
    }
}

//MARK: - WS Of Terms&Conditions
extension TermsAndConditionVC {
    func callWSOfgetTermsUrl(strURL: String){
        
        AFWrapper.requestGETURL(strURL, success: { (JSONResponse) in
            self.stopActivityIndicator()
            print("JSONResponse ", JSONResponse)
            if JSONResponse["status"] as? String == "1"{
                if self.camefrom == "Privacy" {
                    if let policyUrl = JSONResponse["policyUrl"] as? String {
                        self.baseURL = policyUrl
                    }
                }else if self.camefrom == "Terms" {
                    if let termsUrl = JSONResponse["termsUrl"] as? String {
                        self.baseURL = termsUrl
                    }
                }else {
                    self.view.makeToast("No url found")
                }
                DispatchQueue.main.async {
                    self.loadWebView(url: self.baseURL!)
                    //self.webview?.reload()
                }
            }
            else{
                if let errorCode = JSONResponse["errorCode"] as? String {
                    if errorCode == "99" {
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        self.navigationController?.popToRootViewController(animated: true)
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
