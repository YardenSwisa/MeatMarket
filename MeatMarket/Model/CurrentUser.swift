//
//  User.swift
//  MeatMarket
//  Copyright © 2019 YardenSwisa. All rights reserved.


import UIKit
import Firebase

class CurrentUser{
    
    //MARK: Properties
    static let shared = CurrentUser()
    
    let databaseRef = Database.database().reference()
    var allRecipes:[Recipe]
    var meatCuts:[MeatCut]
    var segueId:String
    var vc:UIViewController
    var serverFavoritesNum:Int?
//    var allRecipesURL:[String:URL]
    var user:User?
    var credits:[String:String]
    var didDownloadImage = false
    var image:URL? = nil
//    var myRecipes:[Recipe]
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
//        allRecipesURL = [:]
//        myRecipes = []
        allMyRecipes = []
        
    }
    
    //MARK: Configure Current User
    func configure(userId:String, segueId:String, meatCuts:[MeatCut], vc:UIViewController, credits:[String:String]){
        print("CurrentUser configure called")
        let dataBaseRef = Database.database().reference()
        let storageRef = Storage.storage().reference(forURL: "gs://meat-markett.appspot.com/images/profileImage/")
        let imageRef = storageRef.child(userId)
        
        self.segueId = segueId
        self.vc = vc
//        self.allRecipesURL = allRecipesURL
        self.meatCuts = meatCuts
        self.allRecipes = []
        self.credits = credits
//        self.myRecipes = []
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
                                              timeStemp: nil )
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

                        let image = self.getImageForRecipe(recipeId:recipeId)

                        let recipe = Recipe(
                                            id: recipeData["id"] as! String,
                                            name: recipeData["name"] as! String,
                                            imageName: recipeData["image"] as! String,
                                            image: image,
                                            ingredients: recipeData["ingredients"] as! [String],
                                            instructions: recipeData["instructions"] as! [String],
                                            level: Levels(rawValue: (recipeData["level"] as! Int))!,
                                            time: recipeData["time"] as! String,
                                            rating: 1.0,
                                            creator: recipeData["creator"] as? String ?? nil,
                                            meatcutID: recipeData["meatcutID"] as! String,
                                            meatcutName: recipeData["meatcutName"] as? String )
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
                        let image = self.getImageForRecipe(recipeId:recipeId)

                        let recipe = Recipe(
                                            id: recipeData["id"] as! String,
                                            name: recipeData["name"] as! String,
                                            imageName: recipeData["image"] as! String,
                                            image: image,
                                            ingredients: recipeData["ingredients"] as! [String],
                                            instructions: recipeData["instructions"] as! [String],
                                            level: Levels(rawValue: (recipeData["level"] as! Int))!,
                                            time: recipeData["time"] as! String,
                                            rating: 1.0,
                                            creator: recipeData["creator"] as? String ?? nil,
                                            meatcutID: recipeData["meatcutID"] as! String,
                                            meatcutName: recipeData["meatcutName"] as? String )
                        self.allMyRecipes.append(recipe)
                        //                            print("userFavoritesData.keys.count: \(userFavoritesData.keys.count)")
                    }
                }
            })
        }
        

        
        
        Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.loadUser(_:)), userInfo: nil, repeats: true)
        
    }
    
    // getting the image for specific recipe
    func getImageForRecipe(recipeId:String)->URL?{
        for i in 0..<MyData.shared.allMeatCuts.count {
                for x in 0..<MyData.shared.allMeatCuts[i].recipes!.count{
                    if recipeId == MyData.shared.allMeatCuts[i].recipes![x].id{
                        return MyData.shared.allMeatCuts[i].recipes![x].image
                    }
                }
                
        }
        return nil
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
//        allRecipesURL = [:]
//        myRecipes = []
    }
    
    //MARK: @objc load User
    @objc func loadUser(_ timer:Timer){
        if serverFavoritesNum != nil , serverFavoritesNum == allRecipes.count, didDownloadImage, serverMyRecipesNum != nil , serverMyRecipesNum == allMyRecipes.count{
            timer.invalidate()
            self.user!.setImageUrl(url: self.image)
            self.user!.setRecipes(favorite: allRecipes, allMyRecipes: allMyRecipes)
            let dic:[String:Any] = [
                                    "meatCuts":self.meatCuts,
//                                    "allRecipesURL":self.allRecipesURL,
                                    "credits":self.credits ]
            vc.performSegue(withIdentifier: segueId, sender: dic)
        }
        
    }
    
    //MARK: Add/Remove Favorite
    func addToFavorite(recipe:Recipe, vc:UIViewController, delegate:RecipeCellFavoriteStatusDelegate){
        databaseRef.child("Favorites").child(user!.id!).child(recipe.id).setValue(ServerValue.timestamp()) { (Error, DatabaseReference) in
            delegate.changeStatus()
        }
        user!.addToFavorite(recipe: recipe)
        HelperFuncs.showToast(message: "Added to favorites", view: vc.view)
    }
    
//    func removeFromFavorites(recipeId: String){
//                databaseRef.child("Favorites").child(user!.id!).child(recipeId).removeValue { (error, DatabaseReference) in
//                    
//                    if error == nil {
//                        print("DELETED?")
//                        self.user!.removeFromFavorite(recipeId: recipeId)
//                    }
//                }
//        
//                HelperFuncs.showToast(message: "Removed from favorites", view: vc.view)
//            
//    }
    
        func removeFromFavorite(recipe:Recipe, vc:UIViewController, delegate:Any){
            databaseRef.child("Favorites").child(user!.id!).child(recipe.id).removeValue { (error, DatabaseReference) in

                if error != nil {
//                    self.user!.removeFromFavorite(recipeId: recipe.id)
                }
                if let delegate = delegate as? RecipeCellFavoriteStatusDelegate{
                    print("trying to delete")
                    delegate.changeStatus()
                    self.user!.removeFromFavorite(recipeId: recipe.id)
                }
                if let delegate = delegate as? RemoveFavoriteProtocol{
                    delegate.removeFavorite(recipeId: recipe.id)
                }

            }
            HelperFuncs.showToast(message: "Removed from favorites", view: vc.view)
        }
            func removeFromMyRecipes(recipe:Recipe, vc:UIViewController, delegate:RemoveMyRecipeProtocol){
                databaseRef.child("UsersRate").child(recipe.id).removeValue { (error, DatabaseReference) in      }
                databaseRef.child("MyRecipes").child(user!.id!).child(recipe.id).removeValue { (error, DatabaseReference) in      }
                databaseRef.child("AllRecipes").child(recipe.id).removeValue { (error, DatabaseReference) in      }
                databaseRef.child("Recipes").child(recipe.meatcutID).child(recipe.id).removeValue { (error, DatabaseReference) in      }
                Storage.storage().reference().child("images/recipesImages/").child(recipe.id).delete { (Error) in
                    
                }
                
//                - ALLRECIPES
//                - RECIPES
//                - MY RECIPES
//                -  STORAGE
//                - userate
                for i in 0..<CurrentUser.shared.user!.favoriteRecipes.count {
                    if recipe.id == CurrentUser.shared.user!.favoriteRecipes[i].id{
                        databaseRef.child("Favorites").child(user!.id!).child(recipe.id).removeValue { (error, DatabaseReference) in
                        }
                    }

                }
                var rememberX = -1
                var rememberI = -1
                for i in 0..<MyData.shared.allMeatCuts.count {
                    if recipe.meatcutID == MyData.shared.allMeatCuts[i].id{
                        for x in 0..<MyData.shared.allMeatCuts[i].recipes!.count{
                            if recipe.id == MyData.shared.allMeatCuts[i].recipes![x].id{
                                rememberX = x
                                rememberI = i
                            }
                        }
                        
                    }

                }
                if rememberX != -1 && rememberI != -1{
                     MyData.shared.allMeatCuts[rememberI].recipes!.remove(at: rememberX)

                }
                delegate.removeMyRecipe(recipeId: recipe.id)

                HelperFuncs.showToast(message: "Removed from favorites", view: vc.view)
            }
    
}


