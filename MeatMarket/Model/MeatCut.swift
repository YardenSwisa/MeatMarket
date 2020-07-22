//
//  MeatCut.swift
//  MeatMarket
//  Copyright © 2019 YardenSwisa. All rights reserved.


import UIKit

struct MeatCut: Equatable{
    static func == (lhs: MeatCut, rhs: MeatCut) -> Bool {
        return lhs.recipes == rhs.recipes
    }
    //MARK: Properties
    let id:String
    let name:String
    let image:URL?
    var recipes:[Recipe]?
}
