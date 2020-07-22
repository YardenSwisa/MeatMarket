//
//  InstructionsTableViewCell.swift
//  MeatMarket
//
//  Created by YardenSwisa on 14/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

import UIKit

class InstructionsTableViewCell: UITableViewCell {
    //MARK: OutLets
    @IBOutlet weak var instructionLable: UILabel!
    
    //MARK: LifeCycle ViewCell
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
