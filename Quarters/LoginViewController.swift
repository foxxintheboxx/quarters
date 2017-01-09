//
//  LoginViewController.swift
//  Quarters
//
//  Created by Ian Fox on 1/5/17.
//  Copyright © 2017 Quarters Inc. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit



class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    

    @IBOutlet var navigationBarTitle: UINavigationItem!

    var userName : UITextView?
    var pictureView : FBSDKProfilePictureView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(FBSDKAccessToken.current() == nil) {
            print("Not logged in.")
        } else {
            print("viewDidLoad: logged in.")
            self.performSegue(withIdentifier:"pushFeedViewController", sender: self)
        }
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushFeedViewController" {
            print("pushing feed view controller")
        } else if segue.identifier == "pushPlaidLinkViewController" {
            print("push plaid link view controller")
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if(error == nil) {
            self.performSegue(withIdentifier: "pushPlaidLinkViewController", sender: self)
            print(FBSDKAccessToken.current().tokenString)
            print("Logged in!")
        } else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        FBSDKLoginManager().logOut()
        FBSDKAccessToken.setCurrent(nil)
        self.userName?.text = "";
        self.pictureView?.profileID = "";
        print("Logged out!")
    }

}
