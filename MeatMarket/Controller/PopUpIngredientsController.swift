//
//  PopUpIngredientsViewController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 11/04/2020.
//  Copyright © 2020 YardenSwisa. All rights reserved.
//

import UIKit
import Prestyler

//MARK: Protocols
protocol MovePopupsDataToCreateRecipe: class {
    func getIngredients(ingredients: [String])
    func getInstructions(instructions: [String])
}

//MARK: Class
class PopUpIngredientsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Outlets
    @IBOutlet weak var ingredientsTV: UITableView!
    @IBOutlet weak var ingredientsTF: UITextField!
    
    //MARK:
    var userIngredient =  ""
    var userIngredients:[String] = []
    weak var delegate:MovePopupsDataToCreateRecipe?
    
    //MARK: LifeSycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientsTV.delegate = self
        ingredientsTV.dataSource = self
        ingredientsTV.setNoDataMassege(EnterMassege: "Add Ingredients...")
        
        ingredientsTF.becomeFirstResponder()
        
        textFieldSetup()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK: Actions
    @IBAction func addIngredientTapped(_ sender: UIButton) {
        if ingredientsTF.text?.count != 0{
            userIngredient = ingredientsTF.text!
            userIngredients.append(userIngredient)
            
            delegate?.getIngredients(ingredients: userIngredients)
            
            ingredientsTF.text = ""
            ingredientsTF.becomeFirstResponder()
        }else{
            HelperFuncs.showToast(message: "Please enter Ingredient", view: self.view)
        }
        ingredientsTV.reloadData()
    }
    
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userIngredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Colors difineRules
        Prestyler.defineRule("customOrange", "#CF5C36")
        //Text setup
        let dotStr = "•"
        let ingredientsStr = "\(userIngredients[indexPath.row])"
        //PreStyled Text setup
        let finalText = "\(dotStr) \(ingredientsStr)".prefilter(text: dotStr, by: "customOrange")
        //Cell setup
        let cell = tableView.dequeueReusableCell(withIdentifier: "createIngredientsCellID") as! CreateRecipeIngredientsTableViewCell
        
        cell.backgroundColor = .clear
        cell.labelCell.textColor = .white
        cell.labelCell.attributedText = finalText.prestyled()
        
        ingredientsTV.removeNoDataMassege()
        ingredientsTV.setNoDataMassege(EnterMassege: "To Remove Ingredient Swipe Left")
        
        return cell
    }
    
    // delete in swipe
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            userIngredients.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //MARK: TextField Setup
    fileprivate func textFieldSetup() {
        ingredientsTF.backgroundColor = .white
        ingredientsTF.borderStyle = .roundedRect
        ingredientsTF.attributedPlaceholder = NSAttributedString(string: "Enter ingredient for your recipe...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
    }
}
