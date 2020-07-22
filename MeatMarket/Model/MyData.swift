//
//  MyData.swift
//  MeatMarket
//
//  Created by YardenSwisa on 16/07/2020.
//  Copyright © 2020 YardenSwisa. All rights reserved.
//

import Foundation

class MyData{
    static let shared = MyData()
    
    var allMeatCuts:[MeatCut]
    var allImagesLinks:[String]
    var initRecipeObserverOnce:Bool
    
    private init(){
        allMeatCuts = []
        allImagesLinks = []
        initRecipeObserverOnce = true
    }
    
    func configure(allMeatCuts: [MeatCut], allImagesLinks: [String]){
        self.allMeatCuts = allMeatCuts
        self.allImagesLinks = allImagesLinks
        initRecipeObserverOnce = true
    }
    
}
