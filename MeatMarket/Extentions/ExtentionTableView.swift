//
//  ExtentionTableViewNoDataMassege.swift
//  MeatMarket
//
//  Created by YardenSwisa on 23/04/2020.
//  Copyright © 2020 YardenSwisa. All rights reserved.
//

import UIKit

extension UITableView {
    //MARK: Set massege at the cell backround(cell nil)
    func setNoDataMassege(EnterMassege massege: String){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
    
        label.text = massege
        label.textColor = UIColor(white: 0, alpha: 0.5)
        label.textAlignment = .center
        label.sizeToFit()
        
        self.isScrollEnabled = false
        self.backgroundView = label
        self.separatorStyle = .none
        
    }
    
    //MARK: Remove the massage backround cell(data added)
    func removeNoDataMassege(){
        self.isScrollEnabled = true
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
