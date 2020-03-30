//
//  HomeController.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/28/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import LBTATools
import WebKit
import Alamofire
import SDWebImage

class HomeController: LBTAListController<UserPostCell, Post>, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func handleShowPostDetailsAndComments(post: Post) {
        let postDetailsController = PostDetailsController(postId: post.id)
        navigationController?.pushViewController(postDetailsController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPosts()
        setupDarkandLightMode()
//        setupNavColors()
//        showCookies()
        
        navigationItem.rightBarButtonItem = .init(image: #imageLiteral(resourceName: "search"), style: .plain, target: self, action: #selector(handleSearch))
        navigationItem.leftBarButtonItem = .init(title: "Login", style: .plain, target: self, action: #selector(login))
        
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(fetchPosts), for: .valueChanged)
        self.collectionView.refreshControl = rc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    @objc fileprivate func handleSearch() {
        
        let navController = UINavigationController(rootViewController: UsersSearchController())
        present(navController, animated: true, completion: nil)
    }
    
    @objc fileprivate func createPost() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {return}
        
        dismiss(animated: true) {
            
            let createPostController = CreatePostController(selectedImage: image)
            createPostController.homeController = self
            self.present(createPostController, animated: true, completion: nil)
            

        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    @objc func fetchPosts() {
        print("Fetching...")
        Service.shared.fetchPosts { (res) in
            self.collectionView.refreshControl?.endRefreshing()
            switch res {
            case .failure(let err):
                print("Failed to fetch posts:", err)
            case .success(let posts):
                self.items = posts
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc fileprivate func login() {
        print("Show login and sign up pages")
        let navController = UINavigationController(rootViewController: LoginController())
        present(navController, animated: true)
    }
    
    fileprivate func showCookies() {
        HTTPCookieStorage.shared.cookies?.forEach({ (cookie) in
            print(cookie)
        })
    }
}

extension HomeController {
    
    
    func setupDarkandLightMode(){
        if #available(iOS 12.0, *) {
        let appearance = UINavigationBarAppearance()
        if traitCollection.userInterfaceStyle == .light {
         //Light mode
            navigationController?.navigationBar.tintColor = .black
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            collectionView.backgroundColor = .white

        } else {
          //DARK
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            collectionView.backgroundColor = .black
            navigationController?.navigationBar.tintColor = .white

        }
            
        } else {
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().isTranslucent = false
            collectionView.backgroundColor = .white
            navigationController?.navigationBar.tintColor = .black

        }
    }
    
}

extension HomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
        let height = estimatedCellHeight(for: indexPath, cellWidth: view.frame.width)
        
        return .init(width: view.frame.width, height: height)
    }
}

extension HomeController: PostDelegate {
    func showLikes(post: Post) {
        let likesController = LikesController(postId: post.id)
       
        navigationController?.pushViewController(likesController, animated: true)
    }
    
    func handleLike(post: Post) {
        
        let hasLiked = post.hasLiked == true
        
        let string = hasLiked ? "dislike" : "like"
        let url = "\(Service.shared.baseUrl)/\(string)/\(post.id)"
        AF.request(url, method: .post)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                
                //completion
                
                guard let indexOfPost = self.items.firstIndex(where: {$0.id == post.id}) else { return }
                self.items[indexOfPost].hasLiked?.toggle()
                self.items[indexOfPost].numLikes += hasLiked ? -1 : 1
                let indexPath = IndexPath(item: indexOfPost, section: 0)
                self.collectionView.reloadItems(at: [indexPath])
        }
        
    }
    
    func showOptions(post: Post) {
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(.init(title: "Remove From Feed", style: .destructive, handler: { (_) in
            let url = "\(Service.shared.baseUrl)/feeditem/\(post.id)"
            AF.request(url, method: .delete)
                .validate(statusCode: 200..<300)
                .responseData { (dataResp) in
                    if let err = dataResp.error {
                        print("Failed to delete:", err)
                        return
                    }
                    
                    guard let index = self.items.firstIndex(where: {$0.id == post.id}) else { return }
                    self.items.remove(at: index)
                    self.collectionView.deleteItems(at: [[0, index]])
            }
        }))
        alertController.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true)
    }
    
    func showComments(post: Post) {
        let postDetailsController = PostDetailsController(postId: post.id)
        navigationController?.pushViewController(postDetailsController, animated: true)
    }
    
    
}

