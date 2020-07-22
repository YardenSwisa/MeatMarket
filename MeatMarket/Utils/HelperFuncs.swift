//
//  HelperFuncs.swift
//  MeatMarket
//  Copyright © 2019 YardenSwisa. All rights reserved.

/// HelperFuncs is a class that share methods all over the app for DRY code
import UIKit
import Firebase

struct  HelperFuncs {
    //MARK: Show Toast
    static func showToast(message : String, view: UIView) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150 , y: view.frame.size.height-100, width: 300 , height: 60))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.numberOfLines = 0
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    //MARK: Calculate Recipe Rating
    static func calculateRecipeRating(ratingsData: DataSnapshot)->Double{
        var ratingsAvg = 0.0
        
        if let ratingsData = ratingsData.value as? [String:Any]{
            for userRatingId in ratingsData.keys{
                ratingsAvg = ratingsAvg + (ratingsData[userRatingId] as! Double)
            }
             ratingsAvg = ratingsAvg / Double(ratingsData.keys.count)
            return ratingsAvg 
        }else{
            ratingsAvg = 1.0
            return ratingsAvg
        }
    }
}




