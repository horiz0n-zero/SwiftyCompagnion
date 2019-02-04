//
//  ProjectsTableViewCell.swift
//  SwiftyCompagnion
//
//  Created by Antoine FEUERSTEIN on 1/23/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import UIKit

class ProjectsTableViewCell: UITableViewCell, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var projects: [User.Project] = [] {
        didSet {
            self.tableView.reloadSections(IndexSet.init(integersIn: 0...0), with: .automatic)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "ProjectTableViewCell", bundle: nil), forCellReuseIdentifier: "ProjectTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ProjectTableViewCell", for: indexPath) as! ProjectTableViewCell
        
        cell.fill(with: self.projects[indexPath.row])
        return cell
    }
    
    func addCoalitionColor() {
        for index in 0..<self.projects.count {
            if let cell = self.tableView.cellForRow(at: IndexPath.init(item: index, section: 0)) as? ProjectTableViewCell {
                cell.separator.backgroundColor = UserController.coalitionColor
            }
        }
    }
    
}
