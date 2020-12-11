//
//  ViewController+API_Requests.swift
//  ChumpChange
//
//  Created by Donald on 11/17/20.
//

import Foundation

extension MainScreenViewController {
    
    struct Token: Codable {
        var expiration: String
        var link_token: String
        var request_id: String
    }
    
    
    func getLinkToken(linkTokenCompletionHandler: @escaping (Token?, Error?) -> Void) {
        
        let combinedUrl = "http://" + ip + ":" + port + "/plaid/get_link_token"
        let url = URL(string: combinedUrl)!
        let request = URLRequest(url:url)
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data
            else{ semaphore.signal()
                return }
            do {
                let decoder = JSONDecoder()
                let jsonDict = try decoder.decode(Token.self, from: data)
                if jsonDict.link_token != nil {
                    linkTokenCompletionHandler(jsonDict,nil)
                    semaphore.signal()
                }
            } catch let parseErr {
                print("JSON Parsing Error", parseErr)
                linkTokenCompletionHandler(nil,parseErr)
                semaphore.signal()
            }
        }
        task.resume()
        semaphore.wait()
        
    }
    
    func postAccessToken(accessToken: String) {
        
        let token : [String: Any] = ["public_token" : accessToken, "username" : self.username]
        
        let combinedUrl = "http://" + ip + ":" + port + "/plaid/post_access_token"
        let url = URL(string: combinedUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Applicatoin/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: token)
        request.httpBody = jsonData
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                semaphore.signal()
                print("Error took place \(error)")
                return
            }
            semaphore.signal()
            
        }.resume()
        semaphore.wait()
        
        self.tableData = self.getData(username:self.username, data: self.table)
        self.tableView.reloadData()
    }
    
    //Returns data as [[Account 1][Account2]..[Account x]]
    func getData(username: String, data: String) -> [[String:Any]] {
        let input : [String: Any] = ["username": username]
        var returnData = [[String:Any]]()
        var responseLabel = String()
        
        var website = String()
        
        switch data {
        case "balance":
            responseLabel = "accounts"
            website = "http://" + ip + ":" + port + "/plaid/get_banks"
            break
        case "activity":
            responseLabel = "activity"
            website = "http://" + ip + ":" + port + "/plaid/get_activity"
            break
        default:
            responseLabel = "accounts"
            website = "http://" + ip + ":" + port + "/plaid/get_banks"
            break
        }
        
        let url = URL(string: website)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: input)
        request.httpBody = jsonData
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error took place \(error)")
                semaphore.signal()
                return
            }
            
            if let data = data {
                let jsonString = try? JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                if let jsonData = jsonString {
                    if let response = (jsonData as! [String:[[String:Any]]])[responseLabel] {
                        returnData = response
                    } else { print("Nope") }
                }
                
                semaphore.signal()
            } else {
                print("New Error")
                semaphore.signal()
            }
            
        }.resume()
        semaphore.wait()
        
        
        return returnData
    }
    
    
}
