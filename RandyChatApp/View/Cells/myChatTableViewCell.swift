//
//  myChatTableViewCell.swift
//  RandyChatApp
//
//  Created by Magneto on 10/01/19.
//  Copyright © 2019 Magneto. All rights reserved.
//

import UIKit

class myChatTableViewCell: UITableViewCell {

    //Search Result TableViewCell
    @IBOutlet weak var lblOfSearchResult: UILabel!
    
    //My Profile TableViewCell
    @IBOutlet weak var imgOfProfile: UIImageView!
    @IBOutlet weak var lblOfProfileTitle: UILabel!
    
    //MyProfile Details Fav Topic Cell
    @IBOutlet weak var lblOfFavTopics: UILabel!
    @IBOutlet weak var btnDeleteFavTopic: UIButton!
    
    
    //Notification List TableViewCell
    @IBOutlet weak var lblOfnotificationTitle: UILabel!
    @IBOutlet weak var btnSwitch: UIButton!
    
    //My Chat List TableviewCell
    @IBOutlet weak var viewOfCell: viewOfShadow!
    @IBOutlet weak var profileImage: RoundedImageView!
    @IBOutlet weak var imgOnlineStatus: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblChatCount: UILabel!
    @IBOutlet weak var lblLastChatDate: UILabel!
    @IBOutlet weak var imgNext: UIImageView!
    @IBOutlet weak var lblNewMessageCount: RoundedLbl!
    @IBOutlet weak var lblTopicName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
