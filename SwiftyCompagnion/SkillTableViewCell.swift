//
//  SkillTableViewCell.swift
//  SwiftyCompagnion
//
//  Created by Antoine FEUERSTEIN on 1/24/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import UIKit

class SkillTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var percentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fill(with: User.Skill) {
        self.nameLabel.text = with.name
        self.percentLabel.text = String(with.percent) + " %"
        if UserController.coalitionColor != nil {
            self.nameLabel.textColor = UserController.coalitionColor
        }
    }
    
}
