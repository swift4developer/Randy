//
//  MyChatViewModel.swift
//  RandyChatApp
//
//  Created by Aditya on 14/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit

class MySelectChatViewModel: NSObject {
    
    var myChatArr = [chatDataModel]()
    
    static let sharedInstance :MySelectChatViewModel =
    {
        let instance = MySelectChatViewModel()
        return instance
        
    }()
    
    private override init() {
        
    }
    
    func parseMyChatData(completion: @escaping (([chatDataModel]) -> Void) ,responseData:Any) -> Void
    {
        self.myChatArr.removeAll()
        
        let obj = chatDataModel()
         obj.image = ""
         obj.chatDescription = "Lorem Ipsum is simply dummy text of the printing and  typesetting industry. Lorem Ipsum has been the industry’s standard dummy text ever since the 1500s"
         obj.chatDate = "Feb 12, 2.30 p.m"
         obj.isConsecutiveMyMsg = "0"
         obj.isMyChat = "0"
         self.myChatArr.append(obj)
        
        let obj1 = chatDataModel()
        obj1.image = ""
        obj1.profileImage = ""
        obj1.chatDate = "Feb 12, 2.31 p.m"
        obj1.chatDescription = "Lorem Ipsum is simply dummy text of the printing and  typesetting industry"
        obj1.isConsecutiveMyMsg = "1"
        obj1.isMyChat = "1"
        self.myChatArr.append(obj1)
        
        let obj2 = chatDataModel()
        obj2.image = ""
        obj2.profileImage = ""
        obj2.chatDate = "Feb 10, 8.27 a.m"
        obj2.chatDescription = "Lorem Ipsum is simply dummy text of the printing and  typesetting industry. Lorem Ipsum has been the industry’s standard dummy text ever since the 1500s"
        obj2.isConsecutiveMyMsg = "0"
        obj2.isMyChat = "1"
        self.myChatArr.append(obj2)
        
        
        let obj3 = chatDataModel()
        obj3.image = ""
        obj3.chatDescription = "Lorem Ipsum is simply dummy text of the printing and  typesetting industry"
        obj3.chatDate = "Feb 12, 12.30 p.m"
        obj3.isConsecutiveMyMsg = "0"
        obj3.isMyChat = "0"
        self.myChatArr.append(obj3)
        
        
        completion(self.myChatArr)
    }

}
