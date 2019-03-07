//
//  myChatModel.swift
//  RandyChatApp
//
//  Created by Magneto on 26/02/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import Foundation
import ObjectMapper

class MyChatModel:Mappable {
    var status : String?
    var nextpagenumber: Int?
    var itemsremaining : Int?
    var chatList: [chatList]?
    var message : String?
    var errorCode : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        nextpagenumber <- map["nextpagenumber"]
        itemsremaining <- map["itemsremaining"]
        chatList <- map["chatList"]
        message <- map["message"]
        errorCode <- map["errorCode"]
    }
}


class chatList: Mappable {
    
    
    var groupId : String?
    var discussionTitle:String?
    var totalChatNumber:String?
    var profileImage:String?
    var otherUserProfileImage:String?
    var profileName:String?
    var otherProfileName:String?
    var isActive: String?
    var lastChatTime:String?
    var chatUserId:String?
    var userIsLeave:String?
    var isLeave:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        profileName <- map["profileName"]
        otherProfileName <- map["profileName"]
        groupId <- map["groupId"]
        discussionTitle <- map["discussionTitle"]
        totalChatNumber <- map["totalChatNumber"]
        profileImage <- map["profileImage"]
        otherUserProfileImage <- map["selfProfileImage"]
        isActive <- map["isActive"]
        lastChatTime <- map["lastChatTime"]
        chatUserId <- map["chatUserId"]
        userIsLeave <- map["userIsLeave"]
        isLeave <- map["isLeave"]
    }
    
}
