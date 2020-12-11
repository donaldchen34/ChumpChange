//
//  SpecificBankViewController.swift
//  ChumpChange 1.1
//
//  Created by Donald on 12/9/20.
//

import UIKit

class SpecificBankViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var ip = ""
    var port = ""
    
    @IBOutlet var navBar : UINavigationBar!
    @IBOutlet weak var heading: UINavigationItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var balance: UILabel!

    var username = ""
    var bankName = ""
    var account_id = ""
    var bankBalance = ""
    
    var tableData = [[String:Any]]()
    
    let cellReuseIdentifer = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heading.title = bankName
        balance.text = bankBalance
        
        tableData = getData(username:username)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifer)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifer, for: indexPath) as! UITableViewCell
        
        var tableInfo = [String]()
        for activity in tableData {
            
            var amount = String()
            let storeName = activity["store_name"] as! String
            if let num = activity["amount"] as? Double {
                amount = String(roundNum(num: num))
            } else { amount = "NIL" }
            let date = activity["date"] as! String

            tableInfo.append(storeName + "\n" + date + "..............................." + amount)
        }
        
        cell.textLabel?.text = tableInfo[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.isUserInteractionEnabled = false
        cell.backgroundColor = .lightGray
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = 	UIFont.boldSystemFont(ofSize: 16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int {
            return tableData.count
    }
    

    
    //Returns data as [[Account 1][Account2]..[Account x]]
    func getData(username: String) -> [[String:Any]] {
        let input : [String: Any] = ["username": username]
        var returnData = [[String:Any]]()
        
        
        let combinedUrl = "http://" + ip + ":" + port + "/plaid/get_activity"
        let url = URL(string: combinedUrl)!
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
                    if let response = (jsonData as! [String:[[String:Any]]])["activity"] {
                        for transaction in response{
                            if self.account_id == transaction["account_id"] as! String {
                                returnData.append(transaction)
                            }
                        }
                    } else { print("No Work") }
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

    func roundNum(num: Double) -> Double {
        return Double(round(num * 1000)/1000)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?) {
        if segue.identifier == "SpecificToMain" {
            let destinationViewController = segue.destination as! MainScreenViewController
            destinationViewController.username = self.username
        }
    }
    
}

