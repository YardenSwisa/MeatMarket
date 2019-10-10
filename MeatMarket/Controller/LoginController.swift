//
//  LoginController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 09/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //MARK: Actions
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailField.text else {return}
        guard let password = passwordField.text else {return}

        if email.count == 0 || password.count == 0{
            HelperFuncs.showToast(message: "Please Enter Email And Password", view: view)
        }
        loginWithFireBaseWith()
        
    }
    
    @IBAction func regiserTapped(_ sender: UIButton) {
        let registerationVC = self.storyboard!.instantiateViewController(withIdentifier: "registrationStoryboardID")
        self.present(registerationVC, animated: true, completion: nil)
    }
    
    
    //MARK: LifeCycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print(Levels.levelRecipe(.EASY))

    }
    
    
    //MARK: funcs
    func loginWithFireBaseWith(){
        guard
          let email = emailField.text,
          let password = passwordField.text,
          email.count > 0,
          password.count > 0
          else {
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { user, error in
          if let error = error, user == nil {
            let alert = UIAlertController(title: "Sign In Failed",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alert, animated: true, completion: nil)
          }
            UserDefaults.standard.set("1", forKey: "isLogin")
            let navigationVC = self.storyboard!.instantiateViewController(withIdentifier: "navigationStoryboardID")
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
}
