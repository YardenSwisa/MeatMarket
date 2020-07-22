//
//  CreditsController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 09/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

/// Credits is a credit page for all the recipe i toke from websites online,
/// all recipe have its own url that open safari at that path.
/// for  new recipe by users ther is a creator so thay not include in ther.

import UIKit
import Firebase

class CreditsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    //MARK: Outlets
    @IBOutlet weak var creditsTableView: UITableView!
        
    //MARK: Properties
    var creditsArray:[String] = []
    var urlArray:[String] = []
    var credits:[String:String]?

    //MARK: LifeCycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCredits()
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        creditsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let creditsCell = tableView.dequeueReusableCell(withIdentifier: "creditsCellID") as! CreditsTableViewCell
        
        creditsCell.populate(recipeName:creditsArray[indexPath.row])
        creditsCell.creditCellDelegate = self
        creditsCell.websiteBtn.tag = indexPath.row

        return creditsCell
    }

    //MARK: LoadCredits
    func loadCredits(){
        for creditName in credits!.keys{
            creditsArray.append(creditName)
            urlArray.append(credits![creditName]!)
        }
    }
}
