//
//  File.swift
//  MeatMarket
//
//  Created by YardenSwisa on 09/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Firebase
import SDWebImage

class SplashScreenController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var splashScreenImageGIF: UIImageView!
    
    //MARK: Properties
    var serverMeatCutsCount:Int = 0
    var allMeatCuts:[MeatCut] = []
    var allRecipesURL:[String:URL] = [:]
    var allRecipesSize = 0
    var allRecipes:[Recipe] = []
    var storageLink = "https://firebasestorage.googleapis.com/v0/b/meat-markett.appspot.com/"
    var cowGif = "o/images%2Fgif%2FcowSplashScreen.gif?alt=media&token=9a3c2258-b1b3-4f8f-92f4-5aca1ad8e716"
    var readCredits = false
    var credits:[String:String] = [:]
    var currentRecipesCount = 0
    var serverRecipesCount = 0
    var currentAllMeatCuts:[String:MeatCut] = [:]
    var once = true
    var startTimerOnce = true
    var myRecipes:[String:[Recipe]] = [:]
    
    //MARK: Lifecycle View
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readRealTimeDatabase()
        
        let splashScreenGif = "\(storageLink)\(cowGif)"
        splashScreenImageGIF.sd_setImage(with: URL(string: splashScreenGif))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationVC = segue.destination as? NavigationController{
            guard let dictionary = sender as? [String:Any] else {return}
            
            MyData.shared.allMeatCuts = dictionary["meatCuts"] as! [MeatCut]
            
            navigationVC.credits = dictionary["credits"] as? [String:String]
        }
        
        if let loginVC = segue.destination as? LoginController{
            guard let dictionary = sender as? [String:Any] else {return}
            
            MyData.shared.allMeatCuts = dictionary["meatCuts"] as! [MeatCut]
            
            loginVC.credits = dictionary["credits"] as? [String:String]
        }
    }
    
    
    // MARK: RealTimeDataBase
    func readRealTimeDatabase(){
        let storageRecipesRef = Storage.storage().reference().child("images/recipesImages/")
        let databaseRef = Database.database().reference()
        let meatCutsRef = databaseRef.child("MeatCuts")
        let recipeRef = databaseRef.child("Recipes")
        let ratingRef = databaseRef.child("UsersRate")
        let allRecipesRef = databaseRef.child("AllRecipes")
        
        readCredits = false
        credits = [:]
        
        meatCutsRef.observeSingleEvent(of: .value, with: { (meatCutsData) in
            let meatCuts = meatCutsData.value as! [String:Any]
            
            self.allMeatCuts = []
            self.serverMeatCutsCount = meatCuts.keys.count
            
            for meatCutID in meatCuts.keys{
                self.myRecipes[meatCutID] = []
                
                recipeRef.child(meatCutID).observeSingleEvent(of: .value) { (recipesData) in
                    
                    let recipesData = recipesData.value as! [String:Any?]
                    
                    self.serverRecipesCount += recipesData.keys.count
                    
                    for recipeId in recipesData.keys{
                        ratingRef.child(recipeId).observeSingleEvent(of: .value, with: { (ratingsData) in
                            var ratingsAvg = 0.0
                            ratingsAvg = HelperFuncs.calculateRecipeRating(ratingsData: ratingsData)
                            
                            if self.once{
                                //create and add the recipe to myRecipes(contain all the recipes from the server with rating)
                                allRecipesRef.child(recipeId).observeSingleEvent(of: .value) { (DataSnapshot) in
                                    let data = DataSnapshot.value as! [String:Any]
                                    
                                    let recipe = Recipe(
                                        id: data["id"] as! String,
                                        name: data["name"] as! String,
                                        imageName: data["image"] as! String,
                                        image: nil,
                                        ingredients: data["ingredients"] as! [String],
                                        instructions: data["instructions"] as! [String],
                                        level: Levels(rawValue: data["level"] as! Int)!,
                                        time: data["time"] as! String,
                                        rating: ratingsAvg,
                                        creator: data["creator"] as? String ?? nil,
                                        meatcutID: data["meatcutID"] as! String,
                                        meatcutName: data["meatcutName"] as? String ?? "none")
                                    
                                    self.myRecipes[meatCutID]!.append(recipe)
                                    self.allRecipesSize += 1
                                    
                                    storageRecipesRef.child("\(recipe.id).jpeg").downloadURL {(URL, error) in
                                        if error != nil{
                                            print(error!.localizedDescription)
                                        }
                                        self.allRecipesURL[recipe.id] = URL
                                    }
                                } //observe data
                            }
                        })
                    }
                    
                    let cut = meatCuts[meatCutID] as! [String:Any?]
                    let meatCut = MeatCut(
                        id: cut["id"] as! String,
                        name: cut["name"] as! String,
                        image: nil,
                        recipes: nil )
                    
                    self.currentAllMeatCuts[meatCutID] = meatCut
                    
                    //MARK: Timer
                    if self.startTimerOnce{
                        self.startTimerOnce = false
                        Timer.scheduledTimer(
                            timeInterval: 0.1,
                            target: self,
                            selector: #selector(self.checkRecipesCount(_:)),
                            userInfo: nil,
                            repeats: true )
                    }
                }
            }
            
            //MARK: Credits
            databaseRef.child("Credits").child("RecipesCredits").observeSingleEvent(of: .value) { (creditsData) in
                guard let creditsDictionary = creditsData.value as? [String:String] else {return}
                
                self.credits = creditsDictionary
                self.readCredits = true
            }
        })
    }// realTimeDatabase
    
    @objc func checkRecipesCount(_ timer:Timer){
        let meatCutsStorageRef = Storage.storage().reference().child("images/png/")
        if self.allRecipesSize  == self.serverRecipesCount{
            timer.invalidate()
            for meatCutId in self.currentAllMeatCuts.keys{
                let meatCut = self.currentAllMeatCuts[meatCutId]
                meatCutsStorageRef.child("\(meatCut!.name).png").downloadURL { (url, error) in
                    if let error = error {
                        print("----Error Get images from Storage----", error.localizedDescription)
                        return
                    }
                    
                    let meatCut = MeatCut(
                        id: meatCut!.id,
                        name: meatCut!.name,
                        image: url!,
                        recipes: self.myRecipes[meatCutId]! )
                    self.allMeatCuts.append(meatCut)
                }
            }
            //MARK: Timer
            Timer.scheduledTimer(
                timeInterval: 0.3,
                target: self,
                selector: #selector(self.loadDataEvery(_:)),
                userInfo: nil,
                repeats: true )
        }
    }
    
    //MARK: @Objc funcs
    @objc func loadDataEvery(_ timer:Timer){
        if self.serverMeatCutsCount == self.allMeatCuts.count{
            if self.allRecipesSize == self.allRecipesURL.count {
                if self.readCredits == true{
                    var meatCuts:[MeatCut] = []
                    
                    for meatCut in self.allMeatCuts{
                        var myMeatCut = meatCut
                        
                        myMeatCut.recipes = []
                        
                        for recipe in meatCut.recipes!{
                            var myRecipe = recipe
                            
                            myRecipe.image = allRecipesURL[recipe.id]
                            myMeatCut.recipes!.append(myRecipe)
                        }
                        meatCuts.append(myMeatCut)
                    }
                    checkUserStateLogin(meatCuts: meatCuts)
                    timer.invalidate()
                }
            }
        }
    }
    
    
    
    //MARK: CheckUserStateLogin
    func checkUserStateLogin(meatCuts: [MeatCut]){
        self.liveRating()
        
        if Auth.auth().currentUser != nil {
            self.once = false
            
            MyData.shared.allMeatCuts = meatCuts
            
            CurrentUser.shared.configure(
                userId: Auth.auth().currentUser!.uid,
                segueId: "splashScreenToNavigation",
                meatCuts: meatCuts,
                vc: self,
                credits: credits)
        }else{
            self.once = false
            
            let dic:[String:Any] = [
                "meatCuts": meatCuts,
                "credits": credits ]
            
            self.performSegue(withIdentifier: "splashScreenToLogin", sender: dic)
        }
    }
    
    //MARK: Live Rating
    func liveRating(){
        let dataRef = Database.database().reference()
        
        for i in 0..<MyData.shared.allMeatCuts.count{
            for x in 0..<MyData.shared.allMeatCuts[i].recipes!.count{
                let recipe = MyData.shared.allMeatCuts[i].recipes![x]
                dataRef.child("UsersRate").child(recipe.id).observe(.value) { (ratingsData) in
                    var ratingsAvg = 0.0
                    ratingsAvg = HelperFuncs.calculateRecipeRating(ratingsData: ratingsData)
                    
                    MyData.shared.allMeatCuts[i].recipes![x].rating = ratingsAvg
                }
            }
        }
    }
}
