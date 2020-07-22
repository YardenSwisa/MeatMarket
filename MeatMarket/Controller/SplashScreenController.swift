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
    var splashScreenGif = "https://firebasestorage.googleapis.com/v0/b/meat-markett.appspot.com/o/images%2Fgif%2FcowSplashScreen.gif?alt=media&token=9a3c2258-b1b3-4f8f-92f4-5aca1ad8e716"
    var readCredits = false
    var credits:[String:String] = [:]
    var currentRecipesCount = 0
    var serverRecipesCount = 0
    var currentAllMeatCuts:[String:MeatCut] = [:]
    var once = true
    var startTimerOnce = true
    var myRecipes:[String:[Recipe]] = [:]
//    var userRecipes:[String:[Recipe]] = [:]
    
    //MARK: Lifecycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        readRealTimeDatabase()
        splashScreenImageGIF.sd_setImage(with: URL(string: splashScreenGif))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationVC = segue.destination as? NavigationController{
            guard let dictionary = sender as? [String:Any] else {return}
            MyData.shared.allMeatCuts = dictionary["meatCuts"] as! [MeatCut]
//            navigationVC.allMeatCuts = dictionary["meatCuts"] as? [MeatCut]
//            navigationVC.allRecipesURL = dictionary["allRecipesURL"] as? [String:URL]
            navigationVC.credits = dictionary["credits"] as? [String:String]
            print("SplashScreen finish, loading NavigationVC")
        }
        
        if let loginVC = segue.destination as? LoginController{
            guard let dictionary = sender as? [String:Any] else {return}
            MyData.shared.allMeatCuts = dictionary["meatCuts"] as! [MeatCut]

//            loginVC.allMeatCuts = dictionary["meatCuts"] as? [MeatCut]
//            loginVC.allRecipesURL = dictionary["allRecipesURL"] as? [String:URL]
            loginVC.credits = dictionary["credits"] as? [String:String]
            
            print("SplashScreen finish, loading LoginVC")
        }
    }
    
    
    // MARK: RealTimeDataBase
    func readRealTimeDatabase(){
        print("readRealTimeDatabase")
        
        readCredits = false
        credits = [:]
        let storageRecipesRef = Storage.storage().reference().child("images/recipesImages/")
        let databaseRef = Database.database().reference()
        let meatCutsRef = databaseRef.child("MeatCuts")
        let recipeRef = databaseRef.child("Recipes")
        let ratingRef = databaseRef.child("UsersRate")
        let allRecipesRef = databaseRef.child("AllRecipes")
        //        let myRecipesRef = databaseRef.child("MyRecipes")
        
        meatCutsRef.observeSingleEvent(of: .value, with: { (meatCutsData) in
            let meatCuts = meatCutsData.value as! [String:Any]
            //            print(meatCuts,"<-------meatcutsData")
            self.allMeatCuts = []
            self.serverMeatCutsCount = meatCuts.keys.count
            
            for meatCutID in meatCuts.keys{
                
                self.myRecipes[meatCutID] = []
                
                recipeRef.child(meatCutID).observeSingleEvent(of: .value) { (recipesData) in
                    
                    let recipesData = recipesData.value as! [String:Any?]
                    self.serverRecipesCount += recipesData.keys.count
                    //                    print(self.serverRecipesCount,"live server recipes count grows")
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
//                                    print(recipe.meatcutName ?? "\(recipe.id) no have meatcutName")
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
                    //                    print(self.currentAllMeatCuts.keys.count,"live count of currentAllMeatCuts")
                    //                    print(self.myRecipes,"curr .. ..entAllMeatCuts.count in recipes observer")
                    
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
                
                //                print(self.currentAllMeatCuts.keys.count,"currentAllMeatCuts.count in meatCuts observer")
                
            }
            
            //            print(self.currentAllMeatCuts.count,"currentAllMeatCuts.count above timer")
            
            //            MARK: Timer
            
            //MARK: Credits
            databaseRef.child("Credits").child("RecipesCredits").observeSingleEvent(of: .value) { (creditsData) in
                guard let creditsDictionary = creditsData.value as? [String:String] else {return}
                self.credits = creditsDictionary
                self.readCredits = true
            }
            
        })
        
        
    }// realTimeDatabase
    
    @objc func checkRecipesCount(_ timer:Timer){
        print("splashScreen checkRecipesCount")
        //        print("checkRecipesCount before if allRecipes:\(self.allRecipesSize)  serverRecipes:\(self.serverRecipesCount)")
        let meatCutsStorageRef = Storage.storage().reference().child("images/png/")
        if self.allRecipesSize  == self.serverRecipesCount{
            //            print("checkRecipesCount passed if allRecipes:\(self.allRecipesSize)  serverRecipes:\(self.serverRecipesCount)")
            timer.invalidate()
            //            print("\(currentAllMeatCuts.keys) currentAllMeatCuts.keys")
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
                        recipes: self.myRecipes[meatCutId]! ) //self.myRecipes[meatCutId]!
                    self.allMeatCuts.append(meatCut)
                    
                }
                
            }
//            print(self.allMeatCuts.count,"<------ allMeatCuts.count")
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
        print("splashScreen loadDataEvery")
        //        print("\(self.serverMeatCutsCount) == \(self.allMeatCuts.count) loadDataEvery first if")
        if self.serverMeatCutsCount == self.allMeatCuts.count{ //MARK:TODO: sometime stuck here, 10 == 0 loadDataEvery first if
            //            print("\(self.allRecipesSize) == \(self.allRecipesURL.count) loadDataEvery second if")
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
        print("splashScreen checkUserStateLogin")
        self.liveRating()

        if Auth.auth().currentUser != nil {
//            guard let userID = CurrentUser.shared.user?.id else { return  }
            self.once = false
            MyData.shared.allMeatCuts = meatCuts
            CurrentUser.shared.configure(
                userId: Auth.auth().currentUser!.uid,
                segueId: "splashScreenToNavigation",
                meatCuts: meatCuts,
//                allRecipesURL: allRecipesURL, // test
                vc: self,
                credits: credits)
        }else{
            self.once = false
            let dic:[String:Any] = [
                "meatCuts": meatCuts,
//                "allRecipesURL": allRecipesURL,// test
                "credits": credits ]
            self.performSegue(withIdentifier: "splashScreenToLogin", sender: dic)
        }
    }

        //MARK: Live Rating
        func liveRating(){
            print("MainScreen liveRating func")
    //        if globalOnce{
    //            globalOnce = false
                let dataRef = Database.database().reference()
                
                for i in 0..<MyData.shared.allMeatCuts.count{
                    for x in 0..<MyData.shared.allMeatCuts[i].recipes!.count{
                        let recipe = MyData.shared.allMeatCuts[i].recipes![x]
                        dataRef.child("UsersRate").child(recipe.id).observe(.value) { (ratingsData) in
                            var ratingsAvg = 0.0
                            ratingsAvg = HelperFuncs.calculateRecipeRating(ratingsData: ratingsData)

                            MyData.shared.allMeatCuts[i].recipes![x].rating = ratingsAvg
                        } //observer
                    }// for recipe
                }// for meatcut
    //        }
        }
        
}
