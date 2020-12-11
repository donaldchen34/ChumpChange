//
//  ViewController.swift
//  ChumpChange 1.1
//
//  Created by Donald on 11/25/20.
//
// Picture : https://www.clipartkey.com/view/oihbib_pixel-mario-coin-png/

import UIKit
import AudioToolbox

class ViewController: UIViewController {

    let ip = ""
    let port = ""
    var username = String()
    
    @IBOutlet var login_Button: UIButton!
    @IBOutlet weak var usernameTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        
        if let username = defaults.string(forKey: "loginName") {
            usernameTxtFld.text = username
        }
    }
    
    
    //stackoverflow.com/questions/43779111/http-request-in-swift-with-post-method-in-swift3
    @IBAction func tapLoginButton()
    {
        let missingInfoAlert = UIAlertController(title: "Missing Information", message: "You did not enter your username or password.", preferredStyle: .alert)
        missingInfoAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        
        if !usernameTxtFld.hasText || !passwordTxtFld.hasText {
            self.present(missingInfoAlert, animated: true)
        } else {
            
            username = usernameTxtFld.text!
            var loginSuccessful = false
            
            let loginInfo : [String: Any] = ["username": usernameTxtFld.text!, "password" : passwordTxtFld.text!]
            
            let combinedUrl = "http://" + ip + ":" + port + "/db/login"
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
                            loginSuccessful = true
                        } else { loginSuccessful = false }
                    }
                    semaphore.signal()
                } else {
                    print("New Error")
                    semaphore.signal()
                }

            }.resume()
            semaphore.wait()
            
            if loginSuccessful {
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
                UserDefaults.standard.set(username, forKey: "loginName")
                self.performSegue(withIdentifier: "LoginToMain", sender: self)
                
                
            } else {
                let invalidInfoAlert = UIAlertController(title: "Incorrect Information", message: "Incorrect username or password", preferredStyle: .alert)
                invalidInfoAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                self.present(invalidInfoAlert, animated: true)
            }
            
        }
    }
    
    //stackoverflow.com/questions/25597820/passing-variables-between-view-controllers-using-a-segue
    override func prepare(for segue: UIStoryboardSegue, sender:Any?) {
        if segue.identifier == "LoginToMain" {
            let destinationViewController = segue.destination as! MainScreenViewController
        
            destinationViewController.username = self.username
            destinationViewController.ip = self.ip
            destinationViewController.port = self.port
        }
        if segue.identifier == "LoginToCreateAccount" {
            let destinationViewController = segue.destination as! CreateAccountViewController
            
            destinationViewController.ip = self.ip
            destinationViewController.port = self.port
        }
    }
    

    
}

