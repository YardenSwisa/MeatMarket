//
//  NavigationController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 09/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    //MARK: Properties
    var allMeatCuts:[MeatCut]?
    var allRecipesURL:[String:URL]?
    var credits:[String:String]?
    
    //MARK: LifeCycle View
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(credits)
    }
}
