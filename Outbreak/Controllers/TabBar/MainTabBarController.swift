//
//  MainTabBarController.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/29/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController,  UITabBarControllerDelegate {
    
    var homeController = HomeController()
    var profileController = ProfileController(userId: "")
    var beacon = DeviceToiBeaconController()
    var tracker = TrackerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beacon.initLocalBeacon()
        let vc = UIViewController()
        vc.view.backgroundColor = .yellow
        
        self.delegate = self
        
        viewControllers = [
            createNavController(viewController: homeController, tabBarImage: #imageLiteral(resourceName: "home")),
            createNavController(viewController: vc, tabBarImage: #imageLiteral(resourceName: "plus")),
            createNavController(viewController: tracker, tabBarImage:  #imageLiteral(resourceName: "icons8-virus-50")),
            createNavController(viewController: profileController, tabBarImage: #imageLiteral(resourceName: "user"))
        ]
        
        setupTabBarColors()
    }
    
    fileprivate func createNavController(viewController: UIViewController, tabBarImage: UIImage) -> UIViewController {
            
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = tabBarImage
        return navController
        
    }
    
    fileprivate func setupTabBarColors() {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                //Light mode
                tabBar.tintColor = .black
                
            } else {
                //DARK
                tabBar.tintColor = .white
            }
        } else {
            // Fallback on earlier versions
            tabBar.tintColor = .black
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewControllers?.firstIndex(of: viewController) == 1 {
            print("selected...")
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            present(imagePicker, animated: true)
            return false
        }
        
        return true
    }
    
    func refreshPosts() {
        homeController.fetchPosts()
        profileController.fetchUserProfile()
    }
    
}

extension MainTabBarController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            dismiss(animated: true) {
                let createPostController = CreatePostController(selectedImage: image)
                self.present(createPostController, animated: true)
            }
        } else {
            dismiss(animated: true)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    
    
}

