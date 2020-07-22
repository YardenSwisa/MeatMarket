//
//  CreateRecipeController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 03/04/2020.
//  Copyright © 2020 YardenSwisa. All rights reserved.
//

/// Create a recipe and share it with the rest of the users,
/// you need to specific a meatcut and for that meatcut create a recipe.
/// the recipe get creatorID that can recognaze the user that create them

import UIKit
import Firebase

//MARK: Class 
class CreateRecipeController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        //MARK: Outlets
    @IBOutlet weak var meatCutPicker: UIPickerView!
    @IBOutlet weak var recipeNameTF: UITextField!
    @IBOutlet weak var levelSegment: UISegmentedControl!
    @IBOutlet weak var ingredientsBtn: UIButton!
    @IBOutlet weak var instructionsBtn: UIButton!
    @IBOutlet weak var recipeImageIV: UIImageView!
    @IBOutlet weak var recipeImageCheckIV: UIImageView!
    @IBOutlet weak var ingredientsCheckIV: UIImageView!
    @IBOutlet weak var instructionsCheckIV: UIImageView!
    @IBOutlet weak var createRecipeBtn: UIButton!
    @IBOutlet weak var recipeTimePicker: UIDatePicker!
    
        //MARK: Properties
    var allMeatCuts:[MeatCut]?
    var userRecipeMeatCut = ""
    var userRecipeLevel:Levels = .EASY
    var userRecipeIngredients:[String] = []
    var userRecipeInstructions:[String] = []
    var userRecipeImage:UIImage? = nil
    let checkImage = #imageLiteral(resourceName: "icons8-checked-1")
    var idPickerMeatCut:String = ""
    var recipeImageURL:URL?

    //MARK: LifeSycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        meatCutPicker.delegate = self
        meatCutPicker.dataSource = self
        
        setupTimePicker(minuteInterval: 1)
        
        self.observeKeybordForPushUpTheView()
        self.hideKeyboardWhenTappedAround()
        
        createRecipeBtn.layer.cornerRadius = 8
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ingredientsCreateID"){
            let displayVC = segue.destination as! PopUpIngredientsController
            
            displayVC.delegate = self
            displayVC.userIngredients = userRecipeIngredients
        }
        
        if(segue.identifier == "instructionsCreateID"){
            let displayVC = segue.destination as! PopUpInstructionsController

            displayVC.delegateUserInstruction = self
            displayVC.userInstructions = userRecipeInstructions
        }
    }
    
    //MARK: Actions
    @IBAction func recipeLevelSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            userRecipeLevel = .EASY
            break
        case 1:
            userRecipeLevel = .MEDIUM
            break
        case 2:
            userRecipeLevel = .HARD
            break
        default:
            userRecipeLevel = .EASY
        }
    }
    
    @IBAction func recipeImageTapped(_ sender: UIButton) {
        // select picture from device
        let imagePicker = UIImagePickerController()
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose Source Camera or Library", preferredStyle: .actionSheet)
        
        imagePicker.delegate = self
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true)
            }else{
                HelperFuncs.showToast(message: "Camera not Available", view: self.view)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(actionSheet, animated: true)
    }
    
    
    @IBAction func instructionsTapped(_ sender: UIButton) {
        
    }
    @IBAction func ingredientsTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func createRecipeTapped(_ sender: UIButton) {
        guard let currentUser = CurrentUser.shared.user else {return}
        guard let userRecipeName = recipeNameTF.text else{return}
        let userTimeRecipe  = String(recipeTimePicker.countDownDuration / 60)
        let userRecipeImageName = userRecipeName.replacingOccurrences(of: " ", with: "_").lowercased()
        let databaseRef = Database.database().reference()
        
        //validation
        if userRecipeMeatCut.isEmpty{
            userRecipeMeatCut = allMeatCuts![0].name
            idPickerMeatCut = allMeatCuts![0].id
        }else if recipeNameTF.text!.isEmpty{
            HelperFuncs.showToast(message: "Please enter recipe Name", view: view)
        }else if Double(userTimeRecipe) == 1.0{
            HelperFuncs.showToast(message: "Please choose time for the Recipe", view: view)
        }else if recipeImageCheckIV.image == nil{
            HelperFuncs.showToast(message: "Please choose image from Camera / Library", view: view)
        }else if userRecipeIngredients.isEmpty{
            HelperFuncs.showToast(message: "Please enter recipe Ingredients", view: view)
        }else if userRecipeInstructions.isEmpty{
            HelperFuncs.showToast(message: "Please enter recipe Instructions", view: view)
        }else{
            //create user recipe
            guard let autoKeyForRecipe = databaseRef.child("AllRecipes").childByAutoId().key else{return}
            let userRecipe = Recipe(
                                    id: autoKeyForRecipe,
                                    name: userRecipeName,
                                    imageName: userRecipeImageName,
                                    image: recipeImageURL ?? nil,
                                    ingredients: userRecipeIngredients,
                                    instructions: userRecipeInstructions,
                                    level: userRecipeLevel,
                                    time: userTimeRecipe,
                                    rating: 1.0,
                                    creator: currentUser.id ,
                                    meatcutID: idPickerMeatCut,
                                    meatcutName: userRecipeMeatCut )
            
            let postRecipe = [
                "id" : userRecipe.id,
                "image" : userRecipe.imageName,
                "ingredients" : userRecipe.ingredients,
                "instructions" : userRecipe.instructions,
                "level" : userRecipe.level.rawValue,
                "name" : userRecipe.name,
                "time" : userRecipe.time,
                "creator" : currentUser.id!,
                "meatcutID" : userRecipe.meatcutID,
                "meatcutName": userRecipeMeatCut] as [String : Any] 
            
            //upload image to storage
            let storageRefRecipesImages = Storage.storage().reference(forURL: "gs://meat-markett.appspot.com/images/recipesImages/").child("\(userRecipe.id).jpeg")
            
            guard let recipeData = userRecipeImage?.jpegData(compressionQuality: 0.5) else {return}
            let metaData = StorageMetadata()
            
            metaData.contentType = "image/jpeg"
            
            storageRefRecipesImages.putData(recipeData, metadata: metaData) { (storageMetaData, error) in
                if error != nil{
                    HelperFuncs.showToast(message: error!.localizedDescription, view: self.view)
                    return
                }else{
                    //upload recipe to database
                    databaseRef.child("AllRecipes").child(autoKeyForRecipe).setValue(postRecipe)
                    databaseRef.child("Recipes").child(self.idPickerMeatCut).updateChildValues([autoKeyForRecipe : "x"])
                    databaseRef.child("MyRecipes").child(currentUser.id!).updateChildValues([autoKeyForRecipe : "x"])
                    
                    CurrentUser.shared.user?.myRecipes.append(userRecipe)
                    
                    print("Create Recipe", userRecipe)
                    self.resetAllTheFields()
                }
            }
        }
    }
    
    
    
    
    //MARK: Time Picker
    fileprivate func setupTimePicker(minuteInterval: Int){
        recipeTimePicker.datePickerMode = UIDatePicker.Mode.countDownTimer
        recipeTimePicker.minuteInterval = minuteInterval
    }
    
    //MARK: image recipe
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        
        recipeImageURL = (info[.imageURL] as! URL)
        recipeImageIV.image = image
        userRecipeImage = image
        recipeImageCheckIV.image = checkImage
        
        dismiss(animated: true)
    }
    
    fileprivate func resetAllTheFields(){
        meatCutPicker.selectRow(0, inComponent: 0, animated: true)
        recipeNameTF.text = ""
        levelSegment.selectedSegmentIndex = 0
        recipeTimePicker.countDownDuration = 1.0
        recipeImageIV.image = nil
        recipeImageCheckIV.image = nil
        ingredientsCheckIV.image = nil
        instructionsCheckIV.image = nil
        
        userRecipeMeatCut = allMeatCuts![0].name
        userRecipeLevel = .EASY
        userRecipeIngredients = []
        userRecipeInstructions = []
        userRecipeImage = nil
    }
    
    //MARK: upload Image
    fileprivate func uploadRecipe(quality: CGFloat, recipe:Recipe, postRecipe: [String:Any]){
        let storageRefRecipesImages = Storage.storage().reference(forURL: "gs://meat-markett.appspot.com/images/recipesImages/").child("\(recipe.id).jpeg")
        
        guard let recipeData = userRecipeImage?.jpegData(compressionQuality: quality) else {return}
        let metaData = StorageMetadata()
        
        metaData.contentType = "image/jpeg"
        
        storageRefRecipesImages.putData(recipeData, metadata: metaData) { (storageMetaData, error) in
            if error != nil{
                HelperFuncs.showToast(message: error!.localizedDescription, view: self.view)
                return
            }
        }
    }
    
    
}

/// Extentions for the Data shared with the Instructions and Ingredients views and for the Picker

//MARK:  Extension Delegate
extension CreateRecipeController: MovePopupsDataToCreateRecipe{
    func getIngredients(ingredients: [String]) {
        userRecipeIngredients = ingredients
        ingredientsCheckIV.image = checkImage
    }
    
    func getInstructions(instructions: [String]) {
        
        userRecipeInstructions = instructions
        instructionsCheckIV.image = checkImage
        print(userRecipeInstructions,"UserInstructions")
    }
    
}

//MARK: Extension UIPicker
extension CreateRecipeController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allMeatCuts!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userRecipeMeatCut = allMeatCuts![row].name
        idPickerMeatCut = allMeatCuts![row].id
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allMeatCuts![row].name
    }
    
}




