//
//  ProfileController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 09/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseDatabase
import FirebaseStorage

//MARK: Class
class ProfileController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UINavigationControllerDelegate , UIImagePickerControllerDelegate{
    //MARK: Outlets
    @IBOutlet weak var profileCollectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var segmentCV: UISegmentedControl!
    
    //MARK: Properties
    var userNameStr:String = ""
    var currentUser = CurrentUser.shared.user!
    
    //MARK: LiveCycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAndLoadProfileImage()
        setLabelUserName()
        
        profileCollectionView.delegate = self
        profileCollectionView.dataSource = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let instructionsVC = segue.destination as? InstructionsController{
            guard let recipe = sender as? Recipe else {return}
            instructionsVC.recipe = recipe
        }
    }
    
    
    //MARK: Actions
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        profileCollectionView.reloadData()
    }
    
    @IBAction func addImageTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose Source Camera or Library", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }else{
                HelperFuncs.showToast(message: "Camera not Available", view: self.view)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: Label User Name
    fileprivate func setLabelUserName() {
        userNameStr = "\(currentUser.firstName!) \(currentUser.lastName!)"
        userNameLabel.text = userNameStr
    }
    //MARK: CollecionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch segmentCV.selectedSegmentIndex {
        case 0:
            return currentUser.favoriteRecipes.count
        case 1:
            return currentUser.myRecipes.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let profileCell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as! FavoriteViewCell
        
        switch segmentCV.selectedSegmentIndex {
        case 0:
            let recipe = currentUser.favoriteRecipes[indexPath.row]
            profileCell.populate(recipe: recipe, vc: self, segmentIndex: 0)
            break
        case 1:
            let recipe = currentUser.myRecipes[indexPath.row]
            profileCell.populate(recipe: recipe, vc: self, segmentIndex: 1)
            break
        default:
            break
        }
        
        return profileCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch segmentCV.selectedSegmentIndex {
        case 0:
            self.performSegue(withIdentifier: "profileToInstructions", sender: currentUser.favoriteRecipes[indexPath.row])
            break
        case 1:
            self.performSegue(withIdentifier: "profileToInstructions", sender: currentUser.myRecipes[indexPath.row])
            break
        default:
            break
        }
        
    }
    
    //MARK:Picker Profile Image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        
        profileImageView.image = image.circleMasked
        
        uploadProfileImage(image, complition: nil)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func uploadProfileImage(_ image: UIImage, complition: ((_ url:String?)->())?){
        let uid = currentUser.id
        let storageRef = Storage.storage().reference(forURL: "gs://meat-markett.appspot.com/images/")
        let storage = storageRef.child("profileImage").child(uid!)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {return}
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storage.putData(imageData, metadata: metaData) { (storageMetaData, error) in
            if error != nil {
                HelperFuncs.showToast(message: error!.localizedDescription, view: self.view)
                print("putData Error: \(error!.localizedDescription)")
                return
            }
        }
    }
    
    fileprivate func checkAndLoadProfileImage() {
        if CurrentUser.shared.user?.image != nil{
            URLSession.shared.dataTask(with: currentUser.image!) { (data, _, error) in
                guard let data = data, error == nil else {return}
                DispatchQueue.main.async() {
                    let image = UIImage(data: data)
                    self.profileImageView.image = image!.circleMasked
                }
            }.resume()
        }
    }
    
    
    
    
}


//MARK: Extension Protocol Remove Favorite
extension ProfileController:RemoveFavoriteProtocol{
    func removeFavorite(recipeId:String){
        for i in 0 ..< currentUser.favoriteRecipes.count {
            if recipeId == currentUser.favoriteRecipes[i].id{
                self.profileCollectionView.deleteItems(at: [IndexPath(row: i, section: 0)])
            }
        }
        
        currentUser.removeFromFavorite(recipeId: recipeId)
        
        self.profileCollectionView.reloadData()
    }
}

extension ProfileController:RemoveMyRecipeProtocol{
    func removeMyRecipe(recipeId:String){
        for i in 0 ..< currentUser.myRecipes.count {
            if recipeId == currentUser.myRecipes[i].id {
                self.profileCollectionView.deleteItems(at: [IndexPath(row: i, section: 0)])
            }
        }
        
        currentUser.removeFromMyRecipes(recipeId: recipeId, vc: self )
        
        for i in 0 ..< currentUser.favoriteRecipes.count {
            if recipeId == currentUser.favoriteRecipes[i].id{
                currentUser.removeFromFavorite(recipeId: recipeId)
            }
        }
        
        self.profileCollectionView.reloadData()
    }
}
