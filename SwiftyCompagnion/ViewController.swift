//
//  ViewController.swift
//  SwiftyCompagnion
//
//  Created by Antoine FEUERSTEIN on 1/21/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    var apiInterface: APIInterface! = nil
    static var shared: ViewController!

    @IBOutlet var textField: UITextField!
    
    static var users: [User] = []
    static var user: User! = nil
    
    static let queue = DispatchQueue.init(label: "com.compagnion.calls", qos: .userInitiated, attributes: .concurrent)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.apiInterface == nil {
            self.apiInterface = APIInterface.init(success: {
                //
            }, failure: { error in
                self.showError(error)
            })
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        self.textField.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController.shared = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            let alert = UIAlertController.init(title: "Error", message: "you have to provide a valid login", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return true
        }
        let loading = UIAlertController.init(title: nil, message: "Please wait", preferredStyle: .alert)
        
        self.apiInterface.request("GET", link: .user(self.textField.text!.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!), parameters: [:], success: { data in
            if let dictionary = data as? [String : Any], dictionary.count != 0 {
                DispatchQueue.main.async {
                    let user = User.init(dictionary: dictionary, login: self.textField.text!.lowercased())
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserController") as! UserController
                    
                    vc.user = user
                    loading.dismiss(animated: true, completion: nil)
                    self.present(vc, animated: true, completion: nil)
                }
            }
            else {
                DispatchQueue.main.async {
                    loading.dismiss(animated: true, completion: {
                        let alert = UIAlertController.init(title: "Error", message: self.textField.text! + " doesn't exist", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }
        }, failure: { _ in
            DispatchQueue.main.async {
                loading.dismiss(animated: true, completion: {
                    let alert = UIAlertController.init(title: "Error", message: self.textField.text! + " doesn't exist", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        })
        self.present(loading, animated: true, completion: nil)
        return true
    }
}

extension UIViewController {
    
    func showError(_ error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
