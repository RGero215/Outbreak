//
//  PostDetailController.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/30/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import LBTATools
import Alamofire
import JGProgressHUD

class PostDetailsController: LBTAListController<CommentCell, Comment> {
    
    let postId: String
    
    init(postId: String) {
        self.postId = postId
        super.init()
    }
    
    lazy var customInputView: CustomInputAccessory = {
        let civ = CustomInputAccessory(frame: .init(x: 0, y: 0, width: view.frame.width, height: 50))
        civ.sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return civ
    }()
    
    @objc fileprivate func handleSend() {
        print(customInputView.textView.text ?? "")
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Submitting..."
        hud.show(in: view)
        
        let params = ["text": customInputView.textView.text ?? ""]
        let url = "\(Service.shared.baseUrl)/comment/post/\(postId)"
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                
                hud.dismiss()
                self.customInputView.textView.text = nil
                self.customInputView.placeholderLabel.isHidden = false
                self.fetchPostDetails()
                
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return customInputView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.keyboardDismissMode = .interactive
        navigationItem.title = "Comments"
        
        setupActivityIndicatorView()
        fetchPostDetails()
    }
    
    fileprivate let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.startAnimating()
        aiv.color = .darkGray
        return aiv
    }()
    
    func fetchPostDetails() {
        let url = "\(Service.shared.baseUrl)/post/\(postId)"
        AF.request(url)
            .responseData { (dataResp) in
                
                self.activityIndicatorView.stopAnimating()
                
                guard let data = dataResp.data else { return }
                
//                let string = String(data: data, encoding: .utf8)
//                print(string)
                
                do {
                    let post = try JSONDecoder().decode(Post.self, from: data)
                    self.items = post.comments ?? []
                    self.collectionView.reloadData()
                } catch {
                    print("Failed to parse post:", error)
                }
        }
    }
    
    fileprivate func setupActivityIndicatorView() {
        collectionView.addSubview(activityIndicatorView)
        activityIndicatorView.anchor(top: collectionView.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 100, left: 0, bottom: 0, right: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PostDetailsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = estimatedCellHeight(for: indexPath, cellWidth: view.frame.width)
        
        return .init(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension ProfileController: PostDelegate {
    
    func showLikes(post: Post) {
        
    }
    
    func handleLike(post: Post) {
        
    
    }
    
    func showOptions(post: Post) {
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(.init(title: "Delete post", style: .destructive, handler: { (_) in
            let url = "\(Service.shared.baseUrl)/post/\(post.id)"
            AF.request(url, method: .delete)
                .validate(statusCode: 200..<300)
                .responseData { (dataResp) in
                    if let err = dataResp.error {
                        print("Failed to delete:", err)
                        return
                    }
                    
                    guard let index = self.items.firstIndex(where: {$0.id == post.id}) else { return }
                    self.items.remove(at: index)
                    self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
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
