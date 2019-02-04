//
//  ProjectTableViewCell.swift
//  SwiftyCompagnion
//
//  Created by Antoine FEUERSTEIN on 1/23/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {

    @IBOutlet var projectLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var retryLabel: UILabel!
    
    @IBOutlet var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func fill(with: User.Project) {
        self.projectLabel.text = with.name
        if with.status == .progress {
            self.statusLabel.text = "In progress ..."
            self.statusLabel.textColor = UIColor.orange
        }
        else {
            self.statusLabel.text = with.note + " /125"
            let value = Int(with.note)!
            
            if value >= 125 {
                self.statusLabel.textColor = UIColor.init(red: 212/255, green: 175/255, blue: 55/255, alpha: 1)
            }
            else if value >= 75 {
                self.statusLabel.textColor = UIColor.green
            }
            else {
                self.statusLabel.textColor = UIColor.red
            }
        }
        self.retryLabel.text = "Retry count : " + with.retry
    }
    
}
