//
//  RegistrationController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 09/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

import UIKit
import Firebase

class RegistrationController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var verifyPasswordField: UITextField!
    
    //MARK: Properties
    var databaseRef = Database.database().reference()
    var credits:[String:String]?
    
    //MARK: LifeCycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))

        self.observeKeybordForPushUpTheView()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationVC = segue.destination as? NavigationController{
            guard let dictionary = sender as? [String:Any] else {return}
//            navigationVC.allMeatCuts = dictionary["meatCuts"] as? [MeatCut]
            navigationVC.credits = dictionary["credits"] as? [String:String]
        }
    }
    
    //MARK: Actions
    @IBAction func registerTapped(_ sender: UIButton) {
        guard let firstName = firstNameField.text else {return}
        guard let lastName = lastNameField.text else {return}
        guard let email = emailField.text else {return}
        guard let password = passwordField.text else {return}
        guard let verifyPassword = verifyPasswordField.text else {return}
        
        if  email.count == 0 ||
            firstName.count == 0 ||
            lastName.count == 0 ||
            password.count == 0 ||
            verifyPassword.count == 0 {
            
            HelperFuncs.showToast(message: "Please Fill all the Fields", view: view)
        }else if password != verifyPassword {
            HelperFuncs.showToast(message: "Password Incompatible", view: view)
        }else{
            creatUserWith(firstName: firstName, lastName: lastName, email: email, password: password)
        }
    }
    @objc func backAction(){
        dismiss(animated: true, completion: nil)
    }
    @IBAction func loginTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Create User
    fileprivate func creatUserWith(firstName:String, lastName:String, email: String, password: String ){
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if let error = error {
                print("-----Error Creat FireBase User----",error.localizedDescription)
                HelperFuncs.showToast(message: error.localizedDescription, view: self.view)
                return
            }
            Auth.auth().signIn(withEmail: email, password: password)
            print("---user: \(String(describing: Auth.auth().currentUser?.displayName)) LoggedIn with Firebase---")
            
            guard let id = Auth.auth().currentUser?.uid else {return}
            let userData:[String:Any?] = [
                "id": id,
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "timeStemp": ServerValue.timestamp()
            ]
            
            self.databaseRef.child("Users").child(id).setValue(userData)

            CurrentUser.shared.user!.loadCurrentUserDetails(id: id, firstName: firstName, lastName: lastName, email: email, timeStemp: nil ) //MARK: need to add myRecipes
            print("----New user created with User----->", CurrentUser.shared.user!.description)
            
            let dic:[String:Any] = ["meatCuts": [], "credits": self.credits!]
            self.performSegue(withIdentifier: "registerToNavigation", sender: dic)
            
        }
    }
    
    
}

