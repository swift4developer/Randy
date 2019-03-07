//
//  ModelClass.swift
//  UserGreenWash
//
//  Created by Magneto on 10/09/18.
//  Copyright © 2018 Magneto. All rights reserved.
//

import Foundation

class TrainerList : NSObject {
    var trainerType = ""
    var trainerID = 0
    
    init(trainerType:String, trainerID:Int) {
        self.trainerType = trainerType
        self.trainerID = trainerID
    }
}
