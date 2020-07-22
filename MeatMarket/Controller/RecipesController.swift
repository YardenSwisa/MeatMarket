//
//  RecipesViewController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 12/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

import UIKit
import Firebase


class RecipesController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, RatingProtocol {
    //MARK:Outlets
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    
    //MARK:Properties
    var allRecipes:[Recipe]?
    var meatCutName = ""
    
    //MARK: LifeCycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeCollectionView.delegate = self
        recipeCollectionView.dataSource = self
        
        allRecipes!.sort(by: { $0.name.lowercased() < $1.name.lowercased() })
        
        setTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cellVisuality()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let instructionsVC = segue.destination as? InstructionsController{
            instructionsVC.ratingDelegate = self
            
            guard let sender = sender as? [String:Any] else {return}
            guard let recipe = sender["recipe"] as? Recipe else {return}
            guard let currentUserRate = sender["currentUserRate"] as? Double else {return}
            
            instructionsVC.recipe = recipe
            instructionsVC.currentUserRate = currentUserRate
        }
    }
    
    //MARK: Protocol Delegate
    func ratingAverage(recipe: Recipe) {
        for i in 0..<MyData.shared.allMeatCuts.count{
            for x in 0..<MyData.shared.allMeatCuts[i].recipes!.count{
                if recipe.id == MyData.shared.allMeatCuts[i].recipes![x].id{
                    MyData.shared.allMeatCuts[i].recipes![x].rating = recipe.rating
                    self.recipeCollectionView.reloadData()
                }
            }
        }
        for x in 0..<self.allRecipes!.count{
            if recipe.id == self.allRecipes![x].id{
                self.allRecipes![x].rating = recipe.rating
            }
        }
    }
    
    fileprivate func updateRates(recipeId:String) -> Double{
        for i in 0..<MyData.shared.allMeatCuts.count{
            for x in 0..<MyData.shared.allMeatCuts[i].recipes!.count{
                if recipeId == MyData.shared.allMeatCuts[i].recipes![x].id{
                    return MyData.shared.allMeatCuts[i].recipes![x].rating
                }
            }
        }
        
        return 0.0
    }
    
    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets (top: 8, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRecipes!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let recipeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCellID", for: indexPath) as! RecipeViewCell
        var recipe = allRecipes![indexPath.row]
        let rate = updateRates(recipeId: recipe.id)
        
        recipe.rating = rate
        recipeCell.populate(recipe: recipe)
        recipeCell.vc = self
        
        return recipeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var dic:[String:Any] = [:]
        dic["recipe"] = allRecipes![indexPath.row]
        Database.database().reference().child("UsersRate").child(allRecipes![indexPath.row].id).child(CurrentUser.shared.user!.id!).observeSingleEvent(of: .value, with: { (currentUserRateData) in
            if let currentUserRateData = currentUserRateData.value as? Double{
                dic["currentUserRate"] = currentUserRateData
            }else{
                dic["currentUserRate"] = 1.0
            }
            self.performSegue(withIdentifier: "recipesToInstructions", sender: dic)
            
        }) { (Error) in
            print("didnt rate", "yossiprint")
            self.performSegue(withIdentifier: "recipesToInstructions", sender: dic)
            
        }
    }
    
    fileprivate func cellVisuality(){
        let cellSize = CGSize(width:recipeCollectionView.bounds.width * 0.9, height:recipeCollectionView.bounds.height * 0.40
        )
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        
        layout.minimumLineSpacing = 25
        recipeCollectionView.setCollectionViewLayout(layout, animated: true)
        
        recipeCollectionView.reloadData()
    }
    
    fileprivate func setTitle() {
        for recipe in allRecipes!{
            meatCutName = recipe.meatcutName!
            title = "Recipes of \(meatCutName.capitalized)"
        }
    }
}




