//
//  MainScreenViewController.swift
//  ChumpChange 1.1
//
//  Created by Donald on 11/27/20.
//  Contains the table view and button functions for the Main Screen

import UIKit
import LinkKit

protocol LinkOAuthHandling {
    var linkHandler: Handler? { get }
    var oauthRedirectUri: URL? { get }
}

class MainScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LinkOAuthHandling{
    
    var ip = ""
    var port = ""
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var heading : UINavigationItem!
    @IBOutlet var navBar : UINavigationBar!
    @IBOutlet var addBank: UIBarButtonItem!
    @IBOutlet var activity: UIBarButtonItem!
    @IBOutlet var balance: UIBarButtonItem!

    
    var tableData = [[String:Any]]()
    var passingIndex = Int()
    
    var table = "balance"
    
    var linkHandler: Handler?
    var username = ""
    let cellReuseIdentifer = "cell"
    
    let oauthNonce: String = { return UUID().uuidString }()
    var oauthRedirectUri: URL? = { URL(string: "<#YOUR_OAUTH_REDIRECT_URI#>") }()
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableData = getData(username:username, data: "bank")
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifer)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false

        heading.title = "Balances"
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if table == "balance" {
            passingIndex = indexPath.row
            self.performSegue(withIdentifier: "MainToSpecific", sender: self)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifer) as! UITableViewCell
        
        var tableInfo = [String]()
        
        if table == "balance" {
            for account in tableData {
                var amount = String()
                let bankName = account["name"] as! String
                if let num = account["balance"] as? Double {
                    amount = String(roundNum(num: num))
                } else {
                    if let num = account["current"] as? Double {
                        amount = String(roundNum(num: num))
                    } else { amount = "0"}
                }
                tableInfo.append(bankName + ".........." + amount)
            }
            cell.isUserInteractionEnabled = true
            cell.textLabel?.text = tableInfo[indexPath.row]
        }
        else if table == "activity" {
            for activity in tableData {
                var amount = String()
                let storeName = activity["store_name"] as! String
                if let num = activity["amount"] as? Double {
                    amount = String(roundNum(num: num))
                } else { amount = "NIL" }
                let date = activity["date"] as! String
                
                tableInfo.append(storeName + "\n" + date + "..............................." + amount)
            }
            cell.isUserInteractionEnabled = false
            cell.textLabel?.text = tableInfo[indexPath.row]
            cell.textLabel?.numberOfLines = 0
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int {
        return tableData.count
    }
    
    func roundNum(num: Double) -> Double {
        return Double(round(num * 1000)/1000)
    }
    
    //From the plaid-demo
    @objc func tapAddBankButton(_ sender: Any?) {
        enum PlaidLinkSampleFlow {
            case linkToken
            case linkPublicKey // for compatability with LinkKit v1
        }
        #warning("Select your desired Plaid Link sample flow")
        let sampleFlow : PlaidLinkSampleFlow = .linkToken
        switch sampleFlow {
            case .linkToken:
            presentPlaidLinkUsingLinkToken()
            case .linkPublicKey:
            presentPlaidLinkUsingPublicKey()
        }
    }
    
    @IBAction func tapBalancesButton() {
        if table != "balance" {
            heading.title = "Balances"
            self.table = "balance"
            tableData = getData(username:username, data: table)
            tableView.reloadData()
        }
    }
    
    @IBAction func tabActivityButton() {
        if table != "activity" {
            heading.title = "Activity"
            self.table = "activity"
            tableData = getData(username:username, data: table)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?) {
        if segue.identifier == "MainToSpecific" {
            let destinationViewController = segue.destination as! SpecificBankViewController
            destinationViewController.bankName = tableData[passingIndex]["name"] as! String
            destinationViewController.username = self.username
            destinationViewController.ip = self.ip
            destinationViewController.port = self.port
            destinationViewController.account_id = tableData[passingIndex]["account_id"] as! String
            
            //Get balance
            if let amount = tableData[passingIndex]["balance"] as? Double{
                destinationViewController.bankBalance = String(roundNum(num: amount))
            } else if let amount = tableData[passingIndex]["current"] as? Double {
                destinationViewController.bankBalance = String(roundNum(num: amount))
            } else { destinationViewController.bankBalance = "0"}
            
        }
        

    }
    
}
