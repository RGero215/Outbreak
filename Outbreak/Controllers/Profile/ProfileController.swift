//
//  ProfileController.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/29/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import LBTATools
import Alamofire
import JGProgressHUD
import SDWebImage

extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = estimatedCellHeight(for: indexPath, cellWidth: view.frame.width)
        
        return .init(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if user == nil {
            return .zero
        }
        
        return .init(width: 0, height: 350)
    }
}

class ProfileController: LBTAListHeaderController<UserPostCell, Post, ProfileHeader> {
    
    func handleFollowUnfollow() {
        guard let user = user else { return }
        let isFollowing = user.isFollowing == true
        let url = "\(Service.shared.baseUrl)/\(isFollowing ? "unfollow" : "follow")/\(user.id)"

        AF.request(url, method: .post)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                print("Success...")
                self.user?.isFollowing = !isFollowing
                self.collectionView.reloadData()
        }
    }
    
    override func setupHeader(_ header: ProfileHeader) {
        super.setupHeader(header)
        
        if user == nil { return }
        
        header.user = self.user
        header.profileController = self
    }
    
    let userId: String
    
    init(userId: String) {
        self.userId = userId
        
        super.init()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.layoutIfNeeded()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    fileprivate let activityIndicatorView: UIActivityIndicatorView = {
           let aiv = UIActivityIndicatorView(style: .whiteLarge)
           aiv.startAnimating()
           aiv.color = .darkGray
           return aiv
       }()
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserProfile()
        setupActivityIndicatorView()
        setupDarkandLightMode()
        
    }
    
    fileprivate func setupActivityIndicatorView() {
        collectionView.addSubview(activityIndicatorView)
        activityIndicatorView.anchor(top: collectionView.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 100, left: 0, bottom: 0, right: 0))
    }
    
    var user: User?
    
    func fetchUserProfile() {
        let currentUserProfileUrl = "\(Service.shared.baseUrl)/profile"
        let publicProfileUrl = "\(Service.shared.baseUrl)/user/\(userId)"
        
        let url = self.userId.isEmpty ? currentUserProfileUrl : publicProfileUrl
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                self.activityIndicatorView.stopAnimating()
                let data = dataResp.data ?? Data()
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    self.user = user
                    self.user?.isEditable = self.userId.isEmpty
                    self.items = user.posts ?? []
                    self.collectionView.reloadData()
                } catch {
                    print("Failed to decode user:", error)
                }
        }
    }
    
    func setupDarkandLightMode(){
        if #available(iOS 12.0, *) {
        let appearance = UINavigationBarAppearance()
        if traitCollection.userInterfaceStyle == .light {
         //Light mode
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

        }
            
        } else {
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().isTranslucent = false
            collectionView.backgroundColor = .white

        }
    }
    
    func handlePositive() {
        
        if user?.isPositive == false {
            let url = "\(Service.shared.baseUrl)/post"
             
             let hud = JGProgressHUD(style: .dark)
             hud.indicatorView = JGProgressHUDRingIndicatorView()
             hud.textLabel.text = "Uploading"
             hud.show(in: view)
             
            
             
             AF.upload(multipartFormData: {(formData) in
                 // form post text
                 formData.append(Data("Positive".utf8), withName: "postBody")

                 //form post image
                 guard let imageData = self.user?.profileImageUrl else {return}
                 do {
                     let data = try Data(contentsOf: URL(string: imageData)!)
                     formData.append(data, withName: "imagefile", fileName: "image", mimeType: "image/jpg")
                 } catch {
                     print("Failed...")
                 }
                 


             }, to: url).uploadProgress(queue: .main) { (progress) in
                 print("Upload progress: \(progress.fractionCompleted)")
                 hud.progress = Float(progress.fractionCompleted)
                 hud.textLabel.text = "Uploading\n\(Int(progress.fractionCompleted * 100))% Complete"
             }.response {(dataResp) in
                 
                 hud.dismiss()
                 
                 switch dataResp.result{
                 case .failure(let err):
                     print("Failed to hit server:", err)
                 case .success:
                     if let code = dataResp.response?.statusCode, code >= 300 {
                         print("Failed to upload with status code ", code)
                         return
                     }
                     let respString = String(data: dataResp.data ?? Data(), encoding: .utf8)
                     print("Successfully created post")
                     print(respString ?? "")

                     self.dismiss(animated: true) {
                         
                         self.collectionView.reloadData()
                     }
                 }
             }
        }
        
        
    }
    
    func handleSymptoms() {
        if user?.hasSymptoms == false {
            let url = "\(Service.shared.baseUrl)/post"
             
             let hud = JGProgressHUD(style: .dark)
             hud.indicatorView = JGProgressHUDRingIndicatorView()
             hud.textLabel.text = "Uploading"
             hud.show(in: view)
             
            
             
             AF.upload(multipartFormData: {(formData) in
                 // form post text
                 formData.append(Data("Symptoms".utf8), withName: "postBody")

                 //form post image
                 guard let imageData = self.user?.profileImageUrl else {return}
                 do {
                     let data = try Data(contentsOf: URL(string: imageData)!)
                     formData.append(data, withName: "imagefile", fileName: "image", mimeType: "image/jpg")
                 } catch {
                     print("Failed...")
                 }
                 


             }, to: url).uploadProgress(queue: .main) { (progress) in
                 print("Upload progress: \(progress.fractionCompleted)")
                 hud.progress = Float(progress.fractionCompleted)
                 hud.textLabel.text = "Uploading\n\(Int(progress.fractionCompleted * 100))% Complete"
             }.response {(dataResp) in
                 
                 hud.dismiss()
                 
                 switch dataResp.result{
                 case .failure(let err):
                     print("Failed to hit server:", err)
                 case .success:
                     if let code = dataResp.response?.statusCode, code >= 300 {
                         print("Failed to upload with status code ", code)
                         return
                     }
                     let respString = String(data: dataResp.data ?? Data(), encoding: .utf8)
                     print("Successfully created post")
                     print(respString ?? "")

                     self.dismiss(animated: true) {
                         
                         self.collectionView.reloadData()
                     }
                 }
             }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
