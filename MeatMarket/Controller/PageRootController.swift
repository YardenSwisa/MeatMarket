//
//  PageRootController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 09/10/2019.
//  Copyright © 2019 YardenSwisa. All rights reserved.
//

import UIKit
import Firebase

class PageRootController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    //MARK: Properties
    lazy var viewCntrollersList:[UIViewController] = {
        let mainScreenVC = self.storyboard!.instantiateViewController(withIdentifier: "mainScreenStoryboardID") as! MainScreenController
        let profileVC = self.storyboard!.instantiateViewController(withIdentifier: "profileStoryboardID") as! ProfileController
        let creditsVC = self.storyboard!.instantiateViewController(withIdentifier: "creditsStoryboardID") as! CreditsController
        let createRecipe = self.storyboard!.instantiateViewController(withIdentifier: "createRecipeStoryboardID") as! CreateRecipeController
        
        return [mainScreenVC, profileVC, createRecipe, creditsVC]
    }()
    var pageControl = UIPageControl()
    var credits:[String:String] = [:]
    var allMeatCuts:[MeatCut] = []
    
    //MARK: LifeCycle View
    override func viewDidLoad() {
        print("pageControllerVC viewDidLoad")
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        if let firstVC = viewCntrollersList.first {
            self.setViewControllers([firstVC], direction: .forward, animated: true)
        }
        
        configurePageControl()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Meat Cuts"
        
        MyData.shared.allMeatCuts.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
        
        allMeatCuts = MyData.shared.allMeatCuts
        
        if let navigationVC = self.navigationController as? NavigationController{
            credits = navigationVC.credits!
        }
    }
    
    //MARK: Actions
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            guard let loginVC = self.storyboard!.instantiateViewController(withIdentifier: "loginStoryboardID") as? LoginController else {return}
            
            guard let navigationVC = self.navigationController as? NavigationController else {return}
            
            loginVC.credits = navigationVC.credits
            
            CurrentUser.shared.logout()
            
            self.present(loginVC, animated: true, completion: nil)
        } catch let signOutError as NSError {
            HelperFuncs.showToast(message: signOutError.localizedDescription, view: view)
        }
    }
    
    //MARK: PageViewController
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewCntrollersList.firstIndex(of: viewController) else {return nil}
        
        let previusIndex = vcIndex - 1
        setTitle(vcIndex: previusIndex)
        
        guard previusIndex >= 0 else {return nil}
        guard viewCntrollersList.count > previusIndex else {return nil}
        
        if previusIndex == 0{
        }else if previusIndex == 1{
            let profileVC = viewCntrollersList[previusIndex] as! ProfileController
            
            if profileVC.profileCollectionView != nil{
                profileVC.profileCollectionView.reloadData()
                
            }else if previusIndex == 2{
                let createRecipe = viewCntrollersList[previusIndex] as! CreateRecipeController
                
                createRecipe.allMeatCuts = allMeatCuts }
        }else if previusIndex == 3{
            let creditsVC = viewCntrollersList[previusIndex] as! CreditsController
            creditsVC.credits = credits }
        
        return viewCntrollersList[previusIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewCntrollersList.firstIndex(of: viewController) else {return nil}
        let nextIndex = vcIndex + 1
        setTitle(vcIndex: nextIndex)
        guard viewCntrollersList.count != nextIndex else {return nil}
        guard viewCntrollersList.count > nextIndex else {return nil}
        
        if nextIndex == 0{
        }else if nextIndex == 1{
            let profileVC = viewCntrollersList[nextIndex] as! ProfileController
            
            if profileVC.profileCollectionView != nil{
                profileVC.profileCollectionView.reloadData() }
        }else if nextIndex == 2{
            let createRecipe = viewCntrollersList[nextIndex] as! CreateRecipeController
            
            createRecipe.allMeatCuts = allMeatCuts
        }else if nextIndex == 3{
            let creditsVC = viewCntrollersList[nextIndex] as! CreditsController
            
            creditsVC.credits = credits }
        
        return viewCntrollersList[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        
        self.pageControl.currentPage = viewCntrollersList.firstIndex(of: pageContentViewController)!
    }
    
    
    //MARK: Page Control
    func configurePageControl() {
        let positionX = UIScreen.main.bounds.width / 2 - 25
        let positionY = UIScreen.main.bounds.maxY - 45
        let width = CGFloat(50)
        let height = CGFloat(40)
        
        self.pageControl = UIPageControl(frame: CGRect(x: positionX,y: positionY,width: width,height: height))
        self.pageControl.numberOfPages = viewCntrollersList.count
        self.pageControl.currentPage = viewCntrollersList.startIndex
        self.pageControl.alpha = 1
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.2666666667, green: 0.2549019608, blue: 0.2509803922, alpha: 1)
        self.pageControl.layer.bounds.size = .init(width: 10, height: 50)
        self.view.addSubview(self.pageControl)
    }
    
    func setTitle(vcIndex:Int){
        switch vcIndex{
        case 0:
            self.navigationItem.title = "Meat Cuts"
            break
        case 1:
            self.navigationItem.title = "Profile"
            break
        case 2:
            self.navigationItem.title = "Create Recipe"
            break
        case 3:
            self.navigationItem.title = "Credits"
            break
        default:
            return
        }
    }
    
    
    
}
