//
//  LoginController + handlers.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

extension LoginController {
    
    func handleLoginRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {
            (user, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            UserDefaults.standard.setIsLoggedIn(value: true)
            
            guard let uid = FIRAuth.auth()?.currentUser?.uid else {
                return
            }
            
            let user = User()
            user.loadUserUsingCacheWithUserId(uid: uid, controller: self)
        })
    }
    
    func fetchUserAndDoSomething(user: User) {
        FIRDatabase.database().reference().child("outstanding-requests-by-user").child(user.charger!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(user.uid!) {
                UserDefaults.standard.setHasPendingRequest(value: true)
            } else {
                UserDefaults.standard.setHasPendingRequest(value: false)
            }
            
            let mc = MasterController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            mc.modalTransitionStyle = .crossDissolve
            self.present(mc, animated: true, completion: nil)
            
        })
        
        if let deviceToken = Model.currentToken {
            FIRDatabase.database().reference().child("users").child(user.uid!).updateChildValues(["token": deviceToken])
        }
    }
    
}
