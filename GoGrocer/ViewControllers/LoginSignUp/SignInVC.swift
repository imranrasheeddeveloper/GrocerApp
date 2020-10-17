//
//  SignInVC.swift
//  GoGrocer
//
//  Created by Komal Gupta on 29/05/20.
//  Copyright © 2020 Komal Gupta. All rights reserved.
//

import UIKit
import IBAnimatable
import Alamofire

class SignInVC: UIViewController {
    
    @IBOutlet weak var txtFieldUserID: AnimatableTextField!
    @IBOutlet weak var txtFieldPassword: AnimatableTextField!
    var myloader = MyLoader()
    var register = [Register_DataClass]()
    var registeredData: Register_DataClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func signInAction(_ sender: Any) {
        serverHitForLogin()
    }
    
    @IBAction func ForgotPasswrdAction(_ sender: Any) {
        let obj = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func signUPAction(_ sender: Any) {
        let obj = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    func serverHitForLogin(){
        
        self.myloader.showLoader(controller: self)
        // email, password, Auth-key
        let dict = ["user_password":txtFieldPassword.text!,"user_phone":txtFieldUserID.text!,"device_id":"testingsimulater"]
        print(dict)
        WebServices().requestWithPost(baseUrl: baseUrlTest, endUrl: "login", parameters: dict, onCompletion: { (responseData) in
            print(responseData)
            let status = responseData["status"] as? String
            if status == "1" {
                do {
                    let decoder = JSONDecoder()
                    self.register = try decoder.decode([Register_DataClass].self, from: JSONSerialization.data(withJSONObject: responseData["data"] as! [[String:Any]], options: []))
                    print(self.register)
                    print(self.register)
                    let storyboard = UIStoryboard.init(name: "Base", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                    self.navigationController?.pushViewController(viewController, animated: true)
                    for item in self.register {
                        if let userID = item.userID {
                            saveStringInDefault(value: userID, key: "userID")
                        }else{
                            saveStringInDefault(value: "", key: "userID")
                        }
                        
                        if let userName = item.userName {
                            saveStringInDefault(value: userName, key: "userName")
                        } else {
                            saveStringInDefault(value: "", key: "userName")
                        }
                        
                        if let userEmail = item.userEmail {
                            saveStringInDefault(value: userEmail, key: "userEmail")
                        } else {
                            saveStringInDefault(value: "", key: "userEmail")
                        }
                        
                        if let userPhone = item.userPhone {
                            saveStringInDefault(value: userPhone, key: "userPhone")
                        } else {
                            saveStringInDefault(value: "", key: "userPhone")
                        }
                        
                         UserDefaults.standard.setValue(true, forKey: "activateLogin")
                    }
                    
                } catch let err {
                    self.myloader.removeLoader(controller: self)
                    print(err)
                }

            } else {
                self.myloader.removeLoader(controller: self)
           //     alert(message: responseData["message"] as? String ?? "Something went wrong", title: "")
                showToast(message: responseData["message"] as? String ?? "Something went wrong", vc: self, normalColor: true)
            }
        }) { (error) in
            print(error!)
        }
        
    }
    
}
