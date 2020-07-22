//
//  ProtocolRecipeRatingAvg.swift
//  MeatMarket
//
//  Created by YardenSwisa on 06/04/2020.
//  Copyright © 2020 YardenSwisa. All rights reserved.
//

/// protocol passd the avg rate to RecipesViewController to Cosmos framework that shows the avg recipe at the cell
import Foundation

protocol RatingProtocol: class {
    func ratingAverage(recipe:Recipe)
}
