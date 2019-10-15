//
//  ProfileController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 09/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate {
    //MARK: Outlets
    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var array = ["First Cell", "Second Cell", "Third Cell", "Fourth Cell", "Fifth Cell"]
    
    //MARK: LiveCycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        favoriteCollectionView.delegate = self
        favoriteCollectionView.dataSource = self
        
        userNameLabel.text = "\(User.shared.firstName!) \(User.shared.lastName!)"
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: CollecionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return User.shared.recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = favoriteCollectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as! FavoriteViewCell
        let recipe = User.shared.recipes[indexPath.row]
        cell.favoriteRecipeName.text = recipe.name
        cell.favoriteRecipeLevel.text =  recipe.level.description
        cell.favoriteRecipeTime.text = recipe.time
        cell.favoriteImageView.roundCorners(.allCorners, radius: 15)
        cell.favoriteImageView.sd_setImage(with: recipe.image)
        
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell \(indexPath.row) tapped")
        self.performSegue(withIdentifier: "profileToInstructions", sender: User.shared.recipes[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let instructionsVC = segue.destination as? InstructionsController{
            guard let recipe = sender as? Recipe else {return}
            instructionsVC.recipe = recipe
        }
    }
    //MARK: Visuality
    //    func cellVisuality(){
    //        let cellSize = CGSize(width:favoriteCollectionView.bounds.width-80, height:0)
    //        let layout = UICollectionViewFlowLayout()
    //        layout.scrollDirection = .vertical
    //        layout.itemSize = cellSize
    ////        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    //        layout.minimumLineSpacing = 25
    //        favoriteCollectionView.setCollectionViewLayout(layout, animated: true)
    //
    //        favoriteCollectionView.reloadData()
    //    }
}


