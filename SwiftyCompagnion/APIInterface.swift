//
//  APIInterface.swift
//  SwiftyCompagnion
//
//  Created by Antoine FEUERSTEIN on 1/21/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

fileprivate let apiBase: String = "https://api.intra.42.fr"

fileprivate let apiGetProject: String = "/v2/users/%d/projects_users"
fileprivate let apiAuthorize: String = "oauth/authorize"
fileprivate let apiAuth: String = "/oauth/token"
fileprivate let apiGetUsers: String = "/v2/users"
fileprivate let apiGetCampus: String = "/v2/campus"
fileprivate let apiGetCampusUsers: String = "/v2/campus/%@/users"
fileprivate let apiGetCoalition: String = "/v2/users/%d/coalitions"
fileprivate let apiGetExpertise: String = "/v2/expertises/%d"

class APIInterface: NSObject {
    
    static fileprivate let uid = "8e50fdb3816f303a8d2956ae4f9fcddee87b6708c21bf880bb905a07f9fcfe8e"
    static fileprivate let secret = "6fe7971f7de01b75620f181a08337efca435ad924c047931b87b9ef74b83e9af"
    
    enum linkType {
        case link(String)
        case getProject(Int)
        case users
        case user(String)
        case campus
        case campusUser(String)
        case coalition(Int)
        case expertise(Int)
        
        func getURL() -> String {
            switch self {
            case .link(let str):
                return apiBase + str
            case .getProject(let userID):
                return apiBase + String.init(format: apiGetProject, userID)
            case .users:
                return apiBase + apiGetUsers
            case .user(let id):
                return apiBase + apiGetUsers + "/" + id
            case .campus:
                return apiBase + apiGetCampus
            case .campusUser(let str):
                return apiBase + String.init(format: apiGetCampusUsers, str)
            case .coalition(let id):
                return apiBase + String.init(format: apiGetCoalition, id)
            case .expertise(let id):
                return apiBase + String.init(format: apiGetExpertise, id)
            }
        }
    }
    
    var accessToken: String! = nil
    var created: Date! = nil
    var expiration: Date! = nil
    
    init(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        super.init()
        if self.needRefresh() {
            self.requestAuthorize(success: success, failure: failure)
        }
        else {
            success()
        }
    }
    
    func needRefresh() -> Bool {
        
        guard let accessToken = UserDefaults.standard.object(forKey: "access") as? String,
            let created = UserDefaults.standard.object(forKey: "created") as? Date,
            let expiration = UserDefaults.standard.object(forKey: "expiration") as? Date else {
            return true
        }
        
        self.accessToken = accessToken
        self.created = created
        self.expiration = expiration
        if self.expiration <= Date().addingTimeInterval(600) {
            return true
        }
        return false
    }
    func requestAuthorize(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        var request = URLRequest.init(url: (apiBase + apiAuth + "?grant_type=client_credentials&client_id=\(APIInterface.uid)&client_secret=\(APIInterface.secret)").url)
        
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request, completionHandler: { data, reponse, error in
            if let error = error {
                failure(error)
            }
            else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    
                    guard let access_token = json["access_token"] as? String, let expire = json["expires_in"] as? TimeInterval, let created = json["created_at"] as? TimeInterval else {
                        return failure(APIInterfaceError.json)
                    }
                    
                    self.accessToken = access_token
                    self.created = Date.init(timeIntervalSince1970: created)
                    self.expiration = self.created.addingTimeInterval(expire)
                    UserDefaults.standard.set(self.accessToken, forKey: "access")
                    UserDefaults.standard.set(self.created, forKey: "created")
                    UserDefaults.standard.set(self.expiration, forKey: "expiration")
                    success()
                }
                catch {
                    failure(error)
                }
            }
        }).resume()
    }
    
    enum APIInterfaceError: Error {
        case json
        case noData
    }
    func request(_ method: String, link: linkType, parameters: [String : String],
                 success: @escaping (Any) -> (),
                 failure: @escaping (Error) -> ()) {
        var linkString = link.getURL() + "?access_token=\(self.accessToken!)"
        
        for parameter in parameters {
            linkString += "&\(parameter.key)=\(parameter.value)"
        }
        print(linkString)
        var request = URLRequest.init(url: linkString.url)
        
        request.httpMethod = method
        if parameters.count > 0 {
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, reponse, error in
            if let error = error {
                return failure(error)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    return success(json)
                }
                catch {
                    return failure(error)
                }
            }
            else {
                return failure(APIInterfaceError.noData)
            }
        })
        
        task.resume()
    }
    
    subscript(toto: String) -> String {
        return toto.lowercased()
    }
}

struct User: Hashable, Equatable {
    
    var hashValue: Int {
        return self.fullName.hashValue ^ self.login.hashValue ^ self.phone.hashValue
    }
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    let fullName: String
    let login: String
    var level: Double
    
    let correctionPoint: String
    let phone: String
    let id: Int
    //let cursusId: Int
    let email: String
    let wallet: String
    
    let imageURL: String
    let location: String
    
    struct Project {
        let name: String
        let note: String
        let retry: String
        enum Status {
            case finished
            case progress
            case none
        }
        var status: User.Project.Status
        
        init(dictionary: [String: Any], id: Int) {
            if let status = dictionary["status"] as? String {
                switch status {
                case "in_progress":
                    self.status = .progress
                case "finished":
                    self.status = .finished
                default:
                    self.status = .none
                }
            }
            else {
                self.status = .none
            }
            if let project = dictionary["project"] as? [String: Any]/*, let _ = project["parent_id"] as? String*/ {
                self.name = project["name"] as? String ?? "???"
            }
            else {
                self.status = .none
                self.name = "???"
            }
            self.note = String(dictionary["final_mark"] as? Int ?? 0)
            self.retry = String(dictionary["occurrence"] as? Int ?? 0)
            if let ids = dictionary["cursus_ids"] as? [Int] {
                if !ids.contains(id) {
                    self.status = .none
                }
            }
        }
    }
    struct Expertise {
        let stars: Int
        let id: Int
        let expertiseId: Int
        
        init(dictionary: [String: Any]) {
            self.stars = dictionary["value"] as? Int ?? 0
            self.id = dictionary["id"] as? Int ?? 0
            self.expertiseId = dictionary["expertise_id"] as? Int ?? 0
        }
    }
    struct Skill {
        let name: String
        let level: Float
        let percent: Float
        
        init(dictionary: [String: Any]) {
            self.name = dictionary["name"] as? String ?? "???"
            self.level = dictionary["level"] as? Float ?? 0
            self.percent = self.level / 20 * 100
        }
    }
    struct Achievement {
        let name: String
        var image: String? = nil
        let description: String
        let kind: String
        let id: Int
        
        init(dictionary: [String: Any]) {
            self.name = dictionary["name"] as? String ?? "???"
            if let img = (dictionary["image"] as? String)?.dropFirst("/uploads/".count) {
                let str = String(img)
                
                self.image = "https://cdn.intra.42.fr/" + str
            }
            self.description = dictionary["description"] as? String ?? "???"
            self.kind = dictionary["kind"] as? String ?? "???"
            self.id = dictionary["id"] as? Int ?? 0
        }
    }
    
    var expertise: [Expertise] = []
    var projects: [Project] = []
    var skills: [Skill] = []
    var achievements: [Achievement] = []
    init(dictionary: [String: Any], login: String) {
        self.login = login
        self.fullName = dictionary["displayname"] as? String ?? "???"
        self.correctionPoint = String((dictionary["correction_point"] as? Int) ?? 0)
        if let phone = dictionary["phone"] as? String, phone.count > 0 {
            self.phone = phone
        }
        else {
            self.phone = "Private"
        }
        self.id = dictionary["id"] as? Int ?? 0
        self.email = dictionary["email"] as? String ?? "nil"
        self.wallet = String(dictionary["wallet"] as? Int ?? 42)
        self.level = 0
        if let cursus = dictionary["cursus_users"] as? [[String : Any]] {
            for cursu in cursus {
                if cursu["cursus_id"] as? Int == 1 {
                    self.level = cursu["level"] as? Double ?? 0
                    if let skills = cursu["skills"] as? [[String: Any]] {
                        for s in skills {
                            self.skills.append(Skill.init(dictionary: s))
                        }
                        self.skills.sort(by: { skill1, skill2 -> Bool in
                            return skill1.percent > skill2.percent
                        })
                    }
                    break
                }
            }
        }
        self.imageURL = dictionary["image_url"] as? String ?? "https://cdn.intra.42.fr/users/small_\(login).jpg"
        self.location = dictionary["location"] as? String ?? "---"
        let cursusId = dictionary["cursus_id"] as? Int ?? 1
        
        if let projectsDictionaries = dictionary["projects_users"] as? [[String: Any]] {
            for dico in projectsDictionaries {
                let project = Project.init(dictionary: dico, id: cursusId)
                
                if project.status != .none {
                    self.projects.append(project)
                }
            }
        }
        if let expertises = dictionary["expertises_users"] as? [[String: Any]] {
            for expertise in expertises {
                self.expertise.append(User.Expertise.init(dictionary: expertise))
            }
        }
        if let achievs = dictionary["achievements"] as? [[String: Any]] {
            for ach in achievs {
                self.achievements.append(User.Achievement.init(dictionary: ach))
            }
            self.achievements.sort { a1, a2 -> Bool in
                return a1.id < a2.id
            }
        }
    }
    
}

extension String {
    var url: URL {
        return URL.init(string: self)!
    }
    var base64: String {
        return self.data(using: String.Encoding.utf8)!.base64EncodedString()
    }
}
