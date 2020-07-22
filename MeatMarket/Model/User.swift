//
//  User.swift
//  MeatMarket
//  Copyright © 2019 YardenSwisa. All rights reserved.


import UIKit
import Firebase

class User: CustomStringConvertible{
    //MARK: Properties
    var id:String?
    var firstName:String?
    var lastName:String?
    var email:String?
    var image:URL?
    var timeStamp: TimeInterval?
    var favoriteRecipes:[Recipe]
    var myRecipes:[Recipe]
    var description: String{
        return "id: \(id!) , firstName: \(firstName!) ,lastName: \(lastName!), Email: \(email!), timeStemp: \(String(describing: timeStamp))"
    }
    
    //MARK: Constructor
    init(){
        self.id = nil
        self.firstName = nil
        self.lastName = nil
        self.email = nil
        self.timeStamp = nil
        self.image = nil
        self.favoriteRecipes = []
        self.myRecipes = []
    }
    
    //MARK: Clear func
    func clear(){
        self.id = nil
        self.firstName = nil
        self.lastName = nil
        self.email = nil
        self.image = nil
        self.timeStamp = nil
        self.favoriteRecipes = []
        self.myRecipes = []
    }
    
    //MARK: Load Current User Details
    func loadCurrentUserDetails(id:String, firstName:String, lastName:String, email:String, timeStemp:TimeInterval?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.timeStamp = timeStemp
        self.favoriteRecipes = []
        self.myRecipes = []
    }
    
    //MARK: Add/Remove Favorite
    func addToFavorite(recipe:Recipe){
        var alreadyHasIt = false
        for myRecipe in favoriteRecipes{
            if myRecipe.id == recipe.id{
                alreadyHasIt = true
            }
        }
        if !alreadyHasIt{
            self.favoriteRecipes.append(recipe)
        }
    }
    func removeFromFavorite(recipeId:String){
        var remember = -1
        for i in 0 ..< self.favoriteRecipes.count{
            if self.favoriteRecipes[i].id == recipeId{
                remember = i
            }
        }
        if remember != -1{
            self.favoriteRecipes.remove(at: remember)
        }
    }
    
    //MARK: Add/Remove myRecipes
    func addToMyRecipes(recipe:Recipe, view:UIView){
        for rec in self.myRecipes{
            if rec.name != recipe.name {
                self.myRecipes.append(recipe)
            }
            HelperFuncs.showToast(message: "Name recipe exist, Choose another name", view: view)
        }
        
    }
    func removeFromMyRecipes(recipeId:String, vc:UIViewController){
        if self.myRecipes == []{
            HelperFuncs.showToast(message: "You dont have recipes to delete", view: vc.view)
        }
        var remember = -1
        for i in 0 ..< self.myRecipes.count {
            if self.myRecipes[i].id == recipeId{
                remember = i
            }
        }
        if remember != -1{
            self.myRecipes.remove(at: remember)
        }
    }
    
    //MARK: Set Recipe/ImageUrl
    func setRecipes(favorite:[Recipe], allMyRecipes:[Recipe]){
        self.favoriteRecipes = favorite
        self.myRecipes = allMyRecipes
    }
    func setImageUrl(url:URL?){
        self.image = url
    }
    
    
    
}


