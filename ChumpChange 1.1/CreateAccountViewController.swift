//
//  CreateAccountViewController.swift
//  ChumpChange 1.1
//
//  Created by Donald on 11/29/20.
//

import UIKit

class CreateAccountViewController: UIViewController {

    var ip = ""
    var port = ""
    
    @IBOutlet var CreateAccount : UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //stackoverflow.com/questions/58952151/strong-password-overlay-on-uitextfield
        if #available(iOS 12, *) {
            password.textContentType = .oneTimeCode
        } else {
            username.textContentType = .init(rawValue: "")
            password.textContentType = .init(rawValue: "")
        }

    }
    
    @IBAction func verifyCreateAccount(){
        let missingInfoAlert = UIAlertController(title: "Missing Information", message: "You did not enter a username or password.", preferredStyle: .alert)
        missingInfoAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        
        if !username.hasText || !password.hasText {
            self.present(missingInfoAlert, animated: true)
        } else {
          
            var validAccountInfo = false
            
            let loginInfo : [String: Any] = ["username": username.text!, "password" : password.text!]
            
            let combinedUrl = "http://" + ip + ":" + port + "/db/create_account"
            let url = URL(string: combinedUrl)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")

            let jsonData = try? JSONSerialization.data(withJSONObject: loginInfo)
            request.httpBody = jsonData
            
            let semaphore = DispatchSemaphore(value: 0)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
  
                if let error = error {
                    print("Error took place \(error)")
                    semaphore.signal()
                    return
                }
                if let data = data {
                    let jsonString = try? JSONSerialization.jsonObject(with: data, options: []) as! [String : Int]
                    if let loginResponse = jsonString {
                        if loginResponse["response"] == 1 {
                            validAccountInfo = true
                        } else { validAccountInfo = false }
                    }
                    semaphore.signal()
                } else {
                    print("New Error")
                    semaphore.signal()
                }

            }.resume()
            semaphore.wait()
            
            if validAccountInfo {
                let accountCreatedAlert = UIAlertController(title: "Account Created", message: "Your account has been sucessfully created", preferredStyle: .alert)
                accountCreatedAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {(action:UIAlertAction!) in self.performSegue(withIdentifier: "CreateAccountToLogin", sender: self
                ) }))
                
                self.present(accountCreatedAlert, animated: true)
                
                //self.performSegue(withIdentifier: "CreateAccountToLogin", sender: self)
            } else {
                let usernameTakenAlert = UIAlertController(title: "Username is taken", message: "Please choose a different username", preferredStyle: .alert)
                usernameTakenAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                self.present(usernameTakenAlert, animated: true)
            }
            
        }
    }



}
