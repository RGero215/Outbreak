//
//  LikesController.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/30/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import LBTATools
import Alamofire

struct Like: Decodable {
    let user: User
}

class LikeCell: LBTAListCell<Like> {
    
    let fullNameLabel = UILabel(text: "Full name")
    let profileImageView = CircularImageView(width: 44, image:  #imageLiteral(resourceName: "user"))
    
    override func setupViews() {
        super.setupViews()
        
        hstack(profileImageView,
               fullNameLabel,
               spacing: 12,
               alignment: .center).withMargins(.allSides(16))
        
        addSeparatorView(leadingAnchor: profileImageView.leadingAnchor)
    }
    
    override var item: Like! {
        didSet {
            fullNameLabel.text = item.user.fullName
            profileImageView.sd_setImage(with: URL(string: item.user.profileImageUrl ?? ""))
        }
    }
}

class LikesController: LBTAListController<LikeCell, Like> {
    
    let postId: String
    
    init(postId: String) {
        self.postId = postId
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Likes"
        setupActivityIndicatorView()
        fetchLikes()
    }
    
    fileprivate func fetchLikes() {
        let url = "\(Service.shared.baseUrl)/likes/\(postId)"
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                self.activityIndicatorView.stopAnimating()
                guard let data = dataResp.data else { return }
                
                do {
                    let likes = try JSONDecoder().decode([Like].self, from: data)
                    self.items = likes
                    self.collectionView.reloadData()
                } catch {
                    print("Failed to decode likes:", error)
                }
                
        }
    }
    
    fileprivate let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.startAnimating()
        aiv.color = .darkGray
        return aiv
    }()
    
    fileprivate func setupActivityIndicatorView() {
        collectionView.addSubview(activityIndicatorView)
        activityIndicatorView.anchor(top: collectionView.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 100, left: 0, bottom: 0, right: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}

extension LikesController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
