//
//  CreditsTableViewCell.swift
//  MeatMarket
//
//  Created by YardenSwisa on 19/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

import UIKit
import SafariServices


class CreditsTableViewCell: UITableViewCell{
    //MARK: Outlets
    @IBOutlet weak var recipeNameLable: UILabel!
    @IBOutlet weak var websiteBtn: UIButton!
    
    //MARK: Properties
    var creditCellDelegate: CreditsController?
   
    //MARK: Actions
    @IBAction func creditBtnTapped(_ sender: UIButton) {
        let urlCredit = creditCellDelegate?.urlArray[sender.tag].description
        
        guard let url = URL(string: urlCredit ?? "") else {return}
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    //MARK: Funcs
    func populate(recipeName:String){
        recipeNameLable.text = recipeName
    }
    
}
