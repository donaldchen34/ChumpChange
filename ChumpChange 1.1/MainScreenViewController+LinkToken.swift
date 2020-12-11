//
//  ViewController+LinkToken.swift
//  LinkDemo-Swift
//
//  Copyright © 2020 Plaid Inc. All rights reserved.
//

import LinkKit

extension MainScreenViewController {
    
    func presentPlaidLinkUsingLinkToken() {

        var linkToken = String()
        
        getLinkToken(linkTokenCompletionHandler: {
            LinkToken, Error in
            if let token = LinkToken?.link_token{
                linkToken = token
            } else {
                //POP OUT SAYING ERROR
            }
        })
        
        // <!-- SMARTDOWN_PRESENT_LINKTOKEN -->
        // With custom configuration using a link_token
        var linkConfiguration = LinkTokenConfiguration(token: linkToken) { success in
            self.postAccessToken(accessToken: success.publicToken)
        }
        linkConfiguration.onExit = { exit in
            if let error = exit.error {
                print("exit with \(error)\n\(exit.metadata)")
            } else {
                print("exit with \(exit.metadata)")
            }
        }
        
        let result = Plaid.create(linkConfiguration)
        switch result {
        case .failure(let error):
            print("Unable to create Plaid handler due to: \(error)")
        case .success(let handler):
            handler.open(presentUsing: .viewController(self))
            linkHandler = handler
        }
        
        // <!-- SMARTDOWN_PRESENT_LINKTOKEN -->
    }
    
    
}
