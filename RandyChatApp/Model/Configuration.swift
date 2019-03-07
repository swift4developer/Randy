//
//  Configuration.swift
//  MalaBes
//
//  Created by PUNDSK006 on 4/18/17.
//  Copyright © 2017 Intechcreative Pvt. Ltt. All rights reserved.
//

import Foundation
import UIKit

// URL Struct
struct Url{
    
    static let baseURL = "http://sale24by7.com/randy_chat_dev/public/index.php/api/"
    //"http://sale24by7.com/randy_chat/public/index.php/api/"
    
}

// MARK: static String Data
struct string{
    //Toast Msg
    static var noInternetConnMsg = NSLocalizedString("Oops !! No Internet. \nPlease check your network connection and try again.", comment: "")
    static var oppsMsg = NSLocalizedString("OOPS!", comment: "")
    static var someThingWrongMsg = NSLocalizedString("Oops !! Something went wrong.", comment: "")
    
    static let GID_CLIENT_ID = "198036592388-4e7rb14oohle5ofnd61jh2d2it7e0055.apps.googleusercontent.com"
   
    static let gcm_key = ""
}

struct userInfo {
    static var userID = UserDefaults.standard.value(forKey: "userid") as? String ?? "0"
    static var privateKey = UserDefaults.standard.value(forKey: "privatekey") as? String ?? ""
}

// MARK: FontAndSize-------------------------------------------------
struct fontAndSize{
    static let menuItemFont = "Nunito-SemiBold"
    static let menuItemFontSize : CGFloat = 15.0
    static let NaviTitleFont = "Nunito-SemiBold"
    static let NaviTitleFontSize : CGFloat = 18.0
    static let errorFont = "Nunito-Regular"
}

// MARK: Color--------------------------------------------------
struct color{
    
    static let pageMenuUnSelect = UIColor(red:84.0/255.0, green:84.0/255.0, blue:84.0/255.0, alpha:1.0)
    
    // theme sky blue color
    static let themeSkyBlue = UIColor(red:0.58, green:0.91, blue:1.00, alpha:1.0)
    
    // theme dark gray color
    static let themeDarkGray = UIColor(red:0.30, green:0.35, blue:0.40, alpha:1.0)
    
    //barTintColor white color
    static let barTintColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
    
    //theme light gray color
    static let themeLightGray = UIColor(red:0.91, green:0.91, blue:0.91, alpha:1.0)
    
    //background opacity color
    static let bgColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:0.5)
}

// MARK:  Device  Detection------------------------------------------------
enum UIUserInterfaceIdiom : Int
{
    case Unspecified
    case Phone
    case Pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5_OR_SE    = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6_7_8      = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P_7P_8P   = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
}

// MARK:  Device OS Version  Detection
struct Version
{
    static let SYS_VERSION_FLOAT = (UIDevice.current.systemVersion as NSString).floatValue
    static let iOS7 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
    static let iOS8 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
    static let iOS9 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
}


struct UserPreference {
    static let UserDetails = "USERDETAILS"
}
struct SendMessageParameters {
    static let groupId = "groupId"
    static let message = "message"
    static let discussionTitle = "discussionTitle"
    static let profileName = "profileName"
    static let lastChatTime = "lastChatTime"
    static let chatUserId = "chatUserId"
    static let userId = "userId"
    static let userEmail = "email"
}

struct Messages {
    var groupId = ""
    var message = ""
    var discussionTitle = ""
    var profileName = ""
    var lastChatTime = ""
    var chatUserId = ""
    var userId  = ""
    var userEmail = ""
    
    init(GroupId: String, Message: String, DiscussionTitle: String, ProfileName: String,LastChatTime: String, ChatUserId: String, UserId: String, UserEmail: String ) {
        groupId = GroupId
        message = Message
        discussionTitle = DiscussionTitle
        profileName = ProfileName
        lastChatTime = LastChatTime
        chatUserId = ChatUserId
        userId = UserId
        userEmail = UserEmail
    }
}


