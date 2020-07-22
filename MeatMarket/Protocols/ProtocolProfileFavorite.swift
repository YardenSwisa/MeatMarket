//
//  ProtocolProfileFavorite.swift
//  MeatMarket
//
//  Created by YardenSwisa on 06/04/2020.
//  Copyright © 2020 YardenSwisa. All rights reserved.
//

/// Protocols for remove recipe from my Favorite and from My Recipes(that i made)
import Foundation

protocol RemoveFavoriteProtocol {
    func removeFavorite(recipeId:String)
}

protocol RemoveMyRecipeProtocol{
    func removeMyRecipe(recipeId:String)
}
