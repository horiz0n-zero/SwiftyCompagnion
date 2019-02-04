//
//  AchievementTableViewCell.swift
//  SwiftyCompagnion
//
//  Created by Antoine FEUERSTEIN on 1/24/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import UIKit
import SVGKit

class AchievementTableViewCell: UITableViewCell {

    @IBOutlet var containerView: UIView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var kindLabel: UILabel!
    
    @IBOutlet var svgContainer: SVGKFastImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.layer.cornerRadius = 4
        self.containerView.layer.borderWidth = 1
        self.containerView.layer.borderColor = UIColor.black.cgColor
    }
    
    func fill(with: User.Achievement) {
        self.nameLabel.text = with.name
        self.descriptionLabel.text = with.description
        self.kindLabel.text = with.kind
        if let image = with.image {
            HeadTableViewCell.fill(from: image, complete: { data in
                DispatchQueue.main.async {
                    self.svgContainer.image = SVGKImage.init(data: data)
                }
            })
        }
        if UserController.coalitionColor != nil {
            self.containerView.layer.borderColor = UserController.coalitionColor.cgColor
        }
    }
    
}










