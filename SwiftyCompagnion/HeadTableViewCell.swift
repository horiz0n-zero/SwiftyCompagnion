//
//  HeadTableViewCell.swift
//  SwiftyCompagnion
//
//  Created by Antoine FEUERSTEIN on 1/23/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import UIKit
import SVGKit

class HeadTableViewCell: UITableViewCell {

    @IBOutlet var fullName: UILabel!
    
    @IBOutlet var imageviewContainer: UIView!
    @IBOutlet var imageViewLogin: UIImageView!
    
    @IBOutlet var infoView: UIView!
    
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var label4: UILabel!
    
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var levelProgress: UIProgressView!
    @IBOutlet var location: UILabel!
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    var coalitionColor: UIColor = UIColor.gray
    
    @IBOutlet var coalitionSVG: UIView!
    var svg: SVGKImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageviewContainer.layer.cornerRadius = 35
        self.imageviewContainer.layer.shadowPath = UIBezierPath.init(roundedRect: CGRect.init(origin: .zero, size: .init(width: 70, height: 70)), cornerRadius: 35).cgPath
        self.imageviewContainer.layer.shadowOffset = CGSize.init(width: 0, height: 8)
        self.imageviewContainer.layer.shadowRadius = 8
        self.imageviewContainer.layer.masksToBounds = false
        
        self.imageViewLogin.layer.cornerRadius = 35
        self.imageViewLogin.layer.masksToBounds = true
        self.infoView.layer.cornerRadius = 4
        self.svg = SVGKFastImageView.init(svgkImage: nil)
        self.svg.translatesAutoresizingMaskIntoConstraints = false
        self.coalitionSVG.addSubview(self.svg)
        NSLayoutConstraint.init(item: self.svg, attribute: .top, relatedBy: .equal, toItem: self.coalitionSVG, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: self.svg, attribute: .bottom, relatedBy: .equal, toItem: self.coalitionSVG, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: self.svg, attribute: .trailing, relatedBy: .equal, toItem: self.coalitionSVG, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: self.svg, attribute: .leading, relatedBy: .equal, toItem: self.coalitionSVG, attribute: .leading, multiplier: 1, constant: 0).isActive = true
    }

    var with: User!
    func fill(with: User) {
        if self.with != nil && self.with == with {
            return
        }
        self.with = with
        ViewController.shared.apiInterface.request("GET", link: .coalition(with.id), parameters: [:], success: { data in
            if let dictionary = (data as! [[String: Any]]).last {
                guard let name = dictionary["name"] as? String, let image = dictionary["image_url"] as? String, let color = dictionary["color"] as? String else {
                    return
                }
                
                HeadTableViewCell.fill(from: image, complete: { data in
                    DispatchQueue.main.async {
                        let image = SVGKImage.init(data: data)
                        
                        self.svg.image = image
                        if let sublayers = self.svg.image.caLayerTree.sublayers {
                            for sublayer in sublayers {
                                if let shape = sublayer as? CAShapeLayer {
                                    shape.fillColor = self.coalitionColor.cgColor
                                }
                                else if let sublayers = sublayer.sublayers {
                                    for layer in sublayers {
                                        if let shape = layer as? CAShapeLayer {
                                            shape.fillColor = self.coalitionColor.cgColor
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
                self.coalitionColor = UIColor.init(hexString: color)
                UserController.coalitionColor = self.coalitionColor
                DispatchQueue.main.async {
                    self.refreshColor()
                    switch name {
                    case "The Federation":
                        self.backgroundImageView.image = UIImage.init(named: "Unknown-2")
                    case "The Order":
                        self.backgroundImageView.image = UIImage.init(named: "Unknown-1")
                    case "The Alliance":
                        self.backgroundImageView.image = UIImage.init(named: "Unknown-3")
                    case "The Assembly":
                        self.backgroundImageView.image = UIImage.init(named: "Unknown")
                    default: break
                    }
                    ViewController.shared.view.layoutIfNeeded()
                }
            }
        }, failure: { _ in })
        self.location.text = with.location
        self.fillLoginImage(user: with)
        self.fullName.text = with.fullName
        self.levelLabel.text = "Level: \(with.level)"
        self.refreshColor()
    }
    
    func refreshColor() {
        self.animateProgress(level: self.with.level)
        self.imageviewContainer.layer.shadowColor = self.coalitionColor.cgColor
        self.infoView.backgroundColor = self.coalitionColor.withAlphaComponent(0.1)
        self.setLabel(label: self.label1, text: "Email: ", result: with.email)
        self.setLabel(label: self.label2, text: "Evalution Points:", result: with.correctionPoint)
        self.setLabel(label: self.label3, text: "Phone: ", result: with.phone)
        self.setLabel(label: self.label4, text: "Wallet: ", result: with.wallet)
        self.location.textColor = self.coalitionColor
    }
    
    func animateProgress(level: Double) {
        self.levelProgress.progressTintColor = self.coalitionColor
        self.levelProgress.setProgress(Float(level.truncatingRemainder(dividingBy: 1)), animated: true)
    }
    
    func setLabel(label: UILabel, text: String, result: String) {
        let attribute = NSMutableAttributedString.init(string: text + result)
        
        attribute.addAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .regular), .foregroundColor: self.coalitionColor], range: NSMakeRange(0, text.count))
        attribute.addAttributes([.font: UIFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: UIColor.white], range: NSMakeRange(text.count, result.count))
        label.attributedText = attribute
    }
    
    static var loginImages: [Int: UIImage] = [:]
    func fillLoginImage(user: User) {
        if let image = HeadTableViewCell.loginImages[user.hashValue] {
            self.imageViewLogin.image = image
        }
        else {
            if let url = URL.init(string: user.imageURL) {
                URLSession.shared.downloadTask(with: url, completionHandler: { url, _, _ in
                    if let fileUrl = url {
                        let image = UIImage.init(data: try! Data.init(contentsOf: fileUrl))
                        
                        DispatchQueue.main.async {
                            self.imageViewLogin.image = image
                            HeadTableViewCell.loginImages[user.hashValue] = image
                            
                        }
                    }
                }).resume()
            }
        }
    }
    func fill(imageUrl: String, complete: @escaping (UIImage) -> ()) {
        if let image = HeadTableViewCell.loginImages[imageUrl.hashValue] {
            complete(image)
        }
        else {
            if let url = URL.init(string: imageUrl) {
                URLSession.shared.downloadTask(with: url, completionHandler: { url, _, _ in
                    if let fileUrl = url {
                        let image = UIImage.init(data: try! Data.init(contentsOf: fileUrl))!
                        
                        DispatchQueue.main.async {
                            complete(image)
                            HeadTableViewCell.loginImages[imageUrl.hashValue] = image
                        }
                    }
                }).resume()
            }
        }
    }
    
    static var svgData: [String: Data] = [:]
    static func fill(from: String, complete: @escaping (Data) -> ()) {
        if let image = HeadTableViewCell.svgData[from] {
            complete(image)
        }
        else {
            if let url = URL.init(string: from) {
                URLSession.shared.downloadTask(with: url, completionHandler: { url, _, _ in
                    if let fileUrl = url {
                        let data = try! Data.init(contentsOf: fileUrl)
                        
                        DispatchQueue.main.async {
                            complete(data)
                            HeadTableViewCell.svgData[from] = data
                        }
                    }
                }).resume()
            }
        }
    }
    
}
extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
     
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}







