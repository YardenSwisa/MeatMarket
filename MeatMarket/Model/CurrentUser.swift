//
//  User.swift
//  MeatMarket
//  Copyright © 2019 YardenSwisa. All rights reserved.


import UIKit
import Firebase

class CurrentUser{
    
    //MARK: Properties
    static let shared = CurrentUser()
    var allRecipes:[Recipe]
    var meatCuts:[MeatCut]
    var segueId:String
    var vc:UIViewController
    var serverFavoritesNum:Int?
    var allRecipesURL:[String:URL]
    var user:User?
    var credits:[String:String]
    var didDownloadImage = false
    var image:URL? = nil
    var myRecipes:[Recipe]
    let databaseRef = Database.database().reference()
    var serverMyRecipesNum:Int?
    var allMyRecipes:[Recipe]

    
    //MARK: Constructor
    private init(){
        print("CurrentUser init called")
        user = User()
        allRecipes = []
        meatCuts = []
        segueId = ""
        credits = [:]
        vc = UIViewController()
        serverFavoritesNum = nil
        allRecipesURL = [:]
        myRecipes = []
        allMyRecipes = []
        
    }
    
    //MARK: Configure Current User
    func configure(userId:String,segueId:String,meatCuts:[MeatCut],allRecipesURL:[String:URL],vc:UIViewController,credits:[String:String]){
        print("CurrentUser configure called")
        let dataBaseRef = Database.database().reference()
        let storageRef = Storage.storage().reference(forURL: "gs://meat-markett.appspot.com/images/profileImage/")
        let imageRef = storageRef.child(userId)
        
        self.segueId = segueId
        self.vc = vc
        self.allRecipesURL = allRecipesURL
        self.meatCuts = meatCuts
        self.allRecipes = []
        self.credits = credits
        self.myRecipes = []
        self.image = nil
        self.didDownloadImage = false
        self.serverFavoritesNum = nil
        
        imageRef.downloadURL { url, error in
            if let error = error {
                print("Image Download Error: \(error.localizedDescription)")
                self.image = .none
                self.didDownloadImage = true
            } else {
                if url != nil{
                    self.image = url
                }
                self.didDownloadImage = true
            }
        }
        
        dataBaseRef.child("Users").child(userId).observeSingleEvent(of: .value) { (userData) in
            guard let userDictionary = userData.value as? [String:Any] else {return}
            self.user!.loadCurrentUserDetails(
                                              id: userId,
                                              firstName: userDictionary["firstName"] as! String,
                                              lastName: userDictionary["lastName"] as! String,
                                              email: userDictionary["email"] as! String,
                                              timeStemp: nil ) //MARK: need to add myRecipes
            //MARK: Favorite
            dataBaseRef.child("Favorites").child(userId).observeSingleEvent(of: .value, with: { (userFavoritesData) in
                guard let userFavoritesData = userFavoritesData.value as? [String:Any] else {
                    self.serverFavoritesNum = 0
                    self.allRecipes = []
                    return
                }
                self.serverFavoritesNum = userFavoritesData.keys.count
                self.allRecipes = []
                //                    print("userFavoritesData.keys: \(userFavoritesData.keys)")
                for recipeId in userFavoritesData.keys{
                    dataBaseRef.child("AllRecipes").child(recipeId).observeSingleEvent(of: .value) { (recipeData) in
                        guard let recipeData = recipeData.value as? [String:Any] else {return}
                        let recipe = Recipe(
                                            id: recipeData["id"] as! String,
                                            name: recipeData["name"] as! String,
                                            imageName: recipeData["image"] as! String,
                                            image: allRecipesURL[recipeId],
                                            ingredients: recipeData["ingredients"] as! [String],
                                            instructions: recipeData["instructions"] as! [String],
                                            level: Levels(rawValue: (recipeData["level"] as! Int))!,
                                            time: recipeData["time"] as! String,
                                            rating: 1.0,
                                            creator: recipeData["creator"] as? String ?? nil,
                                            meatcutID: recipeData["meatcutID"] as! String)
                        self.allRecipes.append(recipe)
                        //                            print("userFavoritesData.keys.count: \(userFavoritesData.keys.count)")
                    }
                }
            })
            //MARK: MyRecipes
            dataBaseRef.child("MyRecipes").child(userId).observeSingleEvent(of: .value, with: { (userMyRecipesData) in
                guard let userMyRecipesData = userMyRecipesData.value as? [String:Any] else {
                    self.serverMyRecipesNum = 0
                    self.allMyRecipes = []
                    return
                }
                self.serverMyRecipesNum = userMyRecipesData.keys.count
                self.allMyRecipes = []
                //                    print("userFavoritesData.keys: \(userFavoritesData.keys)")
                for recipeId in userMyRecipesData.keys{
                    dataBaseRef.child("AllRecipes").child(recipeId).observeSingleEvent(of: .value) { (recipeData) in
                        guard let recipeData = recipeData.value as? [String:Any] else {return}
                        let recipe = Recipe(
                                            id: recipeData["id"] as! String,
                                            name: recipeData["name"] as! String,
                                            imageName: recipeData["image"] as! String,
                                            image: allRecipesURL[recipeId],
                                            ingredients: recipeData["ingredients"] as! [String],
                                            instructions: recipeData["instructions"] as! [String],
                                            level: Levels(rawValue: (recipeData["level"] as! Int))!,
                                            time: recipeData["time"] as! String,
                                            rating: 1.0,
                                            creator: recipeData["creator"] as? String ?? nil,
                                            meatcutID: recipeData["meatcutID"] as! String)
                        self.allMyRecipes.append(recipe)
                        //                            print("userFavoritesData.keys.count: \(userFavoritesData.keys.count)")
                    }
                }
            })
        }
        

        
        
        Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.loadUser(_:)), userInfo: nil, repeats: true)
        
    }
    
    //MARK: Logout
    func logout(){
        credits = [:]
        user!.clear()
        allRecipes = []
        meatCuts = []
        segueId = ""
        vc = UIViewController()
        serverFavoritesNum = nil
        allRecipesURL = [:]
        myRecipes = []
    }
    
    //MARK: @objc load User
    @objc func loadUser(_ timer:Timer){        
        if serverFavoritesNum != nil , serverFavoritesNum == allRecipes.count, didDownloadImage, serverMyRecipesNum != nil , serverMyRecipesNum == allMyRecipes.count{
            timer.invalidate()
            self.user!.setImageUrl(url: self.image)
            self.user!.setRecipes(favorite: allRecipes, allMyRecipes: allMyRecipes)
            let dic:[String:Any] = [
                                    "meatCuts":self.meatCuts,
                                    "allRecipesURL":self.allRecipesURL,
                                    "credits":self.credits ]
            vc.performSegue(withIdentifier: segueId, sender: dic)
        }
        
    }
    
    //MARK: Add/Remove Favorite
    func addToFavorite(recipe:Recipe, vc:UIViewController, delegate:RecipeCellFavoriteStatusDelegate){
        databaseRef.child("Favorites").child(user!.id!).child(recipe.id).setValue(ServerValue.timestamp()) { (Error, DatabaseReference) in
            delegate.changeStatus()
        }
        user!.addFavorite(recipe: recipe)
        HelperFuncs.showToast(message: "Added to favorites", view: vc.view)
    }
    func removeFromFavorite(recipe:Recipe,vc:UIViewController,delegate:Any){
        databaseRef.child("Favorites").child(user!.id!).child(recipe.id).removeValue { (Error, DatabaseReference) in
            if let delegate = delegate as? RecipeCellFavoriteStatusDelegate{
                delegate.changeStatus()
            }
            if let delegate = delegate as? RemoveFavoriteProtocol{
                delegate.refresh(recipeId: recipe.id)
            }
        }
        user!.removeFavorite(recipeId: recipe.id)
        HelperFuncs.showToast(message: "Removed from favorites", view: vc.view)
    }
    
    //MARK: need to add/remove from myRecipes
    func addToMyRecipes(recipe: Recipe, view: UIView){
        databaseRef.child("MyRecipes").child(user!.id!).child(recipe.id).setValue(ServerValue.timestamp()) { (error, DatabaseReference) in
            if error != nil{
                print(error!.localizedDescription, "Error addToMyRecipes()")
            }
        }
        user!.addRecipe(recipe: recipe, view: view)
        HelperFuncs.showToast(message: "Added to favorites", view: view)
    }
    
    func removeFromMyRecipes(recipe:Recipe, view:UIView){
        databaseRef.child("MyRecipes").child(user!.id!).child(recipe.id).removeValue { (error, DatabaseReference) in
            if error != nil{
                print(error!.localizedDescription,"Error removeFromMyRecipes()")
            }
        }
        user!.removeRecipe(recipe: recipe, view: view)
        HelperFuncs.showToast(message: "Removed from favorites", view: view)

    }
    
    
}


