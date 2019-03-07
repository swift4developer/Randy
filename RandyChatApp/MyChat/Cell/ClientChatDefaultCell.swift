//
//  ClientChatDefaultCell.swift
//  RandyChatApp
//
//  Created by Aditya on 14/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit

class ClientChatDefaultCell: UITableViewCell {
    
    
    @IBOutlet weak var chatView: UIView!
    
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var lblChatDescription: UILabel!
    @IBOutlet weak var imageHeightsConstraints: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var chatObject : chatDataModel? {
        didSet {
            guard let chatObject = chatObject else {
                
                return
            }
            
            self.lblDate.text = chatObject.chatDate
            self.lblChatDescription.text = chatObject.chatDescription
             self.imageHeightsConstraints.constant = self.chatView.frame.height
        }
    }
}
