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
    //MARK: Properties
    var credits:[String:String]?
    
    //MARK: Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //MARK: LifeCycle View
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.observeKeybordForPushUpTheView()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationVC = segue.destination as? NavigationController{
            guard let dictionary = sender as? [String:Any] else {return}
            
            navigationVC.credits = dictionary["credits"] as? [String:String]
        }
        
        if let registerVC = segue.destination as? RegistrationController{
            guard let dictionary = sender as? [String:Any] else {return}
            
            MyData.shared.configure(allMeatCuts: dictionary["meatCuts"] as! [MeatCut], allImagesLinks: [])

            registerVC.credits = dictionary["credits"] as? [String:String]
            
        }
    }
    
    
    
    //MARK: Actions
    @IBAction func loginTapped(_ sender: UIButton) {
        sender.layer.cornerRadius = 10
        sender.backgroundColor = UIColor(hex: "#FFCDB2")
        
        guard let email = emailField.text else {return}
        guard let password = passwordField.text else {return}
        
        if email.count == 0 || password.count == 0{
            HelperFuncs.showToast(message: "Please Enter Email And Password", view: view)
        }
        
        loginWithFireBase()
    }
    
    @IBAction func regiserTapped(_ sender: UIButton) {
        sender.layer.cornerRadius = 10
        sender.backgroundColor = UIColor(hex: "#FFCDB2")
        
        let dic:[String:Any] = ["meatCuts":[], "credits": self.credits!]
        
        self.performSegue(withIdentifier: "loginToRegistration", sender: dic)
    }
    
    
    
    //MARK: Login with firebase
    func loginWithFireBase(){
        guard
            let email = emailField.text,
            let password = passwordField.text, email.count > 0, password.count > 0 else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error, user == nil {
                print(error.localizedDescription)
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }else{
                //MARK: Check user - Mydata
                CurrentUser.shared.configure(userId: Auth.auth().currentUser!.uid, segueId: "loginToNavigation", meatCuts: MyData.shared.allMeatCuts, vc: self,credits: self.credits!) 
            }
        }
    }
}
