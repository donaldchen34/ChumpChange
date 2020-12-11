//
//  MainScreenViewController+PlaidSetup.swift
//  ChumpChange 1.1
//
//  Created by Donald on 11/30/20.
//

import UIKit
import LinkKit


extension MainScreenViewController {

    @IBOutlet var button: UIButton!
    @IBOutlet var buttonContainerView: UIView!

       let oauthNonce: String = { return UUID().uuidString }()

        var oauthRedirectUri: URL? = { URL(string: "<#YOUR_OAUTH_REDIRECT_URI#>") }()

        override func viewDidLoad() {
            super.viewDidLoad()
            let linkKitBundle  = Bundle(for: PLKPlaid.self)

            let shadowColor    = #colorLiteral(red: 0.01176470588, green: 0.1921568627, blue: 0.337254902, alpha: 0.1)
            buttonContainerView.layer.shadowColor   = shadowColor.cgColor
            buttonContainerView.layer.shadowOffset  = CGSize(width: 0, height: -1)
            buttonContainerView.layer.shadowRadius  = 2
            buttonContainerView.layer.shadowOpacity = 1
        }

        @IBAction func tapAddBankButton(_ sender: Any?) {
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
    
    
}
