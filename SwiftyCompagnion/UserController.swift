//
//  UserController.swift
//  SwiftyCompagnion
//
//  Created by Antoine FEUERSTEIN on 1/23/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import Foundation
import UIKit

class UserController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var user: User!
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var loginLabel: UILabel!
    static var coalitionColor: UIColor! {
        didSet {
            DispatchQueue.main.async {
                if let cell = UserController.shared.tableView.cellForRow(at: IndexPath.init(item: 0, section: 1)) as? ProjectsTableViewCell {
                    cell.addCoalitionColor()
                }
                UserController.shared.tableView.reloadSections(IndexSet.init(integersIn: 2...4), with: .automatic)
            }
        }
    }
    static var shared: UserController!
    struct Expertise {
        let name: String
        let userExpertise: User.Expertise
        
        init(expertise: User.Expertise, name: String) {
            self.userExpertise = expertise
            self.name = name
        }
    }
    var expertises: [Expertise] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserController.shared = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "HeadTableViewCell", bundle: nil), forCellReuseIdentifier: "HeadTableViewCell")
        self.tableView.register(UINib.init(nibName: "ProjectsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProjectsTableViewCell")
        self.tableView.register(UINib.init(nibName: "ExpertiseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExpertiseTableViewCell")
        self.tableView.register(UINib.init(nibName: "SkillTableViewCell", bundle: nil), forCellReuseIdentifier: "SkillTableViewCell")
        self.tableView.register(UINib.init(nibName: "AchievementTableViewCell", bundle: nil), forCellReuseIdentifier: "AchievementTableViewCell")
        var interval: TimeInterval = 0
        for expertise in self.user.expertise {
            ViewController.queue.asyncAfter(deadline: .now() + interval, execute: {
                ViewController.shared.apiInterface.request("GET", link: .expertise(expertise.expertiseId), parameters: [:], success: { data in
                    let exp = Expertise.init(expertise: expertise, name: (data as! [String: Any])["name"] as? String ?? "Error")
                    
                    self.expertises.append(exp)
                    DispatchQueue.main.async {
                        self.tableView.reloadSections(IndexSet.init(integersIn: 3...3), with: .automatic)
                    }
                }, failure: { _ in })
            })
            interval += 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loginLabel.text = self.user.login
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 {
            return self.user.achievements.count
        }
        if section == 3 {
            return self.expertises.count
        }
        if section == 2 {
            return self.user.skills.count
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "HeadTableViewCell") as! HeadTableViewCell
            
            cell.fill(with: self.user)
            return cell
        }
        else if indexPath.section == 1 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ProjectsTableViewCell", for: indexPath) as! ProjectsTableViewCell
            
            cell.projects = self.user.projects
            return cell
        }
        else if indexPath.section == 2 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "SkillTableViewCell", for: indexPath) as! SkillTableViewCell
            
            cell.fill(with: self.user.skills[indexPath.row])
            return cell
        }
        else if indexPath.section == 3 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ExpertiseTableViewCell", for: indexPath) as! ExpertiseTableViewCell
            
            cell.fill(with: self.expertises[indexPath.row])
            return cell
        }
        else if indexPath.section == 4 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "AchievementTableViewCell", for: indexPath) as! AchievementTableViewCell
            
            cell.fill(with: self.user.achievements[indexPath.row])
            return cell
        }
        return UITableViewCell.init()
    }
}















