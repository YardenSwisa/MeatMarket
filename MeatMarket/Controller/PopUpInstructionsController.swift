//
//  PopUpInstructionsController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 21/04/2020.
//  Copyright © 2020 YardenSwisa. All rights reserved.
//

import UIKit
import Prestyler

//MARK: Class
class PopUpInstructionsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Outlets
    @IBOutlet weak var instructionTF: UITextField!
    @IBOutlet weak var instructionsTV: UITableView!
    
    //MARK: Properties
    var userInstruction =  ""
    var userInstructions:[String] = []
    weak var delegateUserInstruction: MovePopupsDataToCreateRecipe?
    
    //MARK: LifeSycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionsTV.delegate = self
        instructionsTV.dataSource = self
        instructionsTV.setNoDataMassege(EnterMassege: "Add Instruction...")

        instructionTF.becomeFirstResponder()

        textFieldSetup()
   
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK: Actions
    @IBAction func addInstructionTapped(_ sender: UIButton) {
        if instructionTF.text?.count != 0{
            userInstruction = instructionTF.text!
            userInstructions.append(userInstruction)
            
            delegateUserInstruction?.getInstructions(instructions: userInstructions)
            
            instructionTF.text = ""
            instructionTF.becomeFirstResponder()
        }else{
            HelperFuncs.showToast(message: "Please enter Instraction", view: self.view)
        }
        instructionsTV.reloadData()
    }
    
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInstructions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        Colors difineRules
        Prestyler.defineRule("customOrange", "#CF5C36")
//        Text setup
        var arrayCount:[Int] = []
        for index in 0...userInstructions.count{
            arrayCount.append(index)
        }
        let preNum = "\(arrayCount[indexPath.row + 1]).".prefilter(type: .numbers, by: "customOrange").prefilter(text: ".", by: "customOrange")
        let instructionsStr = "\(userInstructions[indexPath.row])"
//        PreStyled Text setup
        let finalText = "\(preNum) \(instructionsStr)"
//        Cell setup
        let cell = tableView.dequeueReusableCell(withIdentifier: "createInstructionsCellID") as! CreateRecipeInstrcuctionTableViewCell
        
        cell.backgroundColor = .clear
        cell.instructionCellLabel?.textColor = .darkGray
        cell.instructionCellLabel?.attributedText = finalText.prestyled()
        
        instructionsTV.removeNoDataMassege()
        instructionsTV.setNoDataMassege(EnterMassege: "To Remove Instruction Swipe Left")

        return cell
    }
    
    // delete in swipe
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            userInstructions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    //MARK: TextField Setup
    fileprivate func textFieldSetup() {
        instructionTF.backgroundColor = .white
        instructionTF.borderStyle = .roundedRect
        instructionTF.attributedPlaceholder = NSAttributedString(string: "Enter instruction for your recipe...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
    }
}

