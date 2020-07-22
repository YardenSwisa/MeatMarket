//
//  RecipeCollectionViewCell.swift
//  MeatMarket
//
//  Created by YardenSwisa on 12/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

import UIKit
class FavoriteViewCell: RoundedCollectionViewCell {
    //MARK: Outlets
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var favoriteRecipeName: UILabel!
    @IBOutlet weak var favoriteRecipeLevel: UILabel!
    @IBOutlet weak var favoriteRecipeTime: UILabel!
    @IBOutlet weak var favoriteMeatCutName: UILabel!
    @IBOutlet weak var favoriteDeleteBtn: UIButton!
    
    //MARK: Properties
    var recipe:Recipe?
    var vc:ProfileController?
    var removeFavoriteDelegate:RemoveFavoriteProtocol?
    var removeMyRecipeDelegate:RemoveMyRecipeProtocol?
    var segmentIndex:Int = 0
    
    //MARK: Actions
    @IBAction func favoriteDeletTapped(_ sender: UIButton) {
        switch segmentIndex {
        case 0:
            CurrentUser.shared.removeFromFavorite(recipe: recipe!, vc: vc!, delegate: removeFavoriteDelegate!)
            break
        case 1:
            CurrentUser.shared.removeFromMyRecipes(recipe: recipe!, vc: vc!, delegate: removeMyRecipeDelegate!)
            break
        default:
            break
        }
    }
    
    func populate(recipe:Recipe, vc: ProfileController,segmentIndex:Int){
        self.favoriteRecipeName.text = recipe.name
        self.favoriteRecipeLevel.text =  recipe.level.description
        self.favoriteRecipeTime.text = "\(timeString(time: TimeInterval(Double(recipe.time) ?? 0)))"
        self.favoriteMeatCutName.text = recipe.meatcutName
        self.favoriteImageView.sd_setImage(with: recipe.image)
        self.favoriteImageView.layer.cornerRadius = 10
        self.recipe = recipe
        self.vc = vc
        self.removeFavoriteDelegate = vc
        self.removeMyRecipeDelegate = vc
        self.layer.borderWidth = 2
        self.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.segmentIndex = segmentIndex
    }
    
    fileprivate func timeString(time: TimeInterval) -> String {
        let hour = Int(time) / 3600
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    
}
