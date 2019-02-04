//
//  ExpertiseTableViewCell.swift
//  SwiftyCompagnion
//
//  Created by Antoine FEUERSTEIN on 1/24/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import UIKit

class ExpertiseTableViewCell: UITableViewCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var starLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.layer.cornerRadius = 4
        self.containerView.layer.borderColor = UIColor.black.cgColor
        self.containerView.layer.borderWidth = 1
        self.containerView.layer.shadowColor = UIColor.black.cgColor
        self.containerView.layer.shadowOffset = .init(width: 0, height: 2)
        self.containerView.layer.masksToBounds = false
        self.containerView.layer.shadowRadius = 2
        self.containerView.layer.shadowOpacity = 0.2
    }
    
    func fill(with: UserController.Expertise) {
        if UserController.coalitionColor != nil {
            self.containerView.layer.borderColor = UserController.coalitionColor.cgColor
            self.containerView.layer.shadowColor = UserController.coalitionColor.cgColor
        }
        self.nameLabel.text = with.name
        var stars: String = ""
        
        for _ in 0..<with.userExpertise.stars {
            stars += "⭐️ "
        }
        self.starLabel.text = stars
    }
    
}
