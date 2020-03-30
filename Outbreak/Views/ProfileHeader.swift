//
//  ProfileHeader.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/29/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import LBTATools


class ProfileHeader: UICollectionReusableView {
    
    let profileImageView = CircularImageView(width: 80)
    
    let followButton = UIButton(title: "Follow", titleColor: .black, font: .boldSystemFont(ofSize: 13), target: self, action: #selector(handleFollow))
    
    let editProfileButton = UIButton(title: "Edit Profile", titleColor: .white, font: .boldSystemFont(ofSize: 13), backgroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), target: self, action: #selector(handleEditProfile))
    
    let postsCountLabel = UILabel(text: "12", font: .boldSystemFont(ofSize: 14), textAlignment: .center)
    let postsLabel = UILabel(text: "Posts", font: .systemFont(ofSize: 13), textColor: .lightGray, textAlignment: .center)
    
    let followersCountLabel = UILabel(text: "500", font: .boldSystemFont(ofSize: 14), textAlignment: .center)
    let followersLabel = UILabel(text: "Followers", font: .systemFont(ofSize: 13), textColor: .lightGray, textAlignment: .center)
    
    let followingCountLabel = UILabel(text: "500", font: .boldSystemFont(ofSize: 14), textAlignment: .center)
    let followingLabel = UILabel(text: "Following", font: .systemFont(ofSize: 13), textColor: .lightGray, textAlignment: .center)
    
    let fullNameLabel = UILabel(text: "Username", font: .boldSystemFont(ofSize: 14))
    let bioLabel = UILabel(text: "Here's an interesting piece of bio that will definitely capture your attention and all the fans around the world.", font: .systemFont(ofSize: 13), textColor: .darkGray, numberOfLines: 0)
    let positiveButton = UIButton(title: "Not Positive", titleColor: .black, font: .boldSystemFont(ofSize: 13), target: self, action: #selector(handlePositive))
    let symptomsButton = UIButton(title: "No Symptoms", titleColor: .black, font: .boldSystemFont(ofSize: 13), target: self, action: #selector(handleSymptoms))
    let healthyButton = UIButton(title: "Is Healty", titleColor: .black, font: .boldSystemFont(ofSize: 13), target: self, action: #selector(handleHealty))
    
    weak var profileController: ProfileController?
    
    @objc fileprivate func handleFollow() {
        profileController?.handleFollowUnfollow()
    }
    
    @objc fileprivate func handlePositive() {
        profileController?.handlePositive()
    }
    
    @objc fileprivate func handleSymptoms() {
        
    }
    
    @objc fileprivate func handleHealty() {
        
    }
    
    @objc fileprivate func handleEditProfile() {
        profileController?.changeProfileImage()
    }
    
    var user: User! {
        didSet {
            
            profileImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: #imageLiteral(resourceName: "user"))
            
//            profileImageView.image = #imageLiteral(resourceName: "user")
            fullNameLabel.text = user.fullName
            
            bioLabel.text = user.bio
            
            followButton.setTitle(user.isFollowing == true ? "Unfollow" : "Follow", for: .normal)
            followButton.backgroundColor = user.isFollowing == true ? .black : .white
            followButton.setTitleColor(user.isFollowing == true ? .white : .black, for: .normal)
            
            if user.isEditable == true {
                followButton.removeFromSuperview()
            } else {
                editProfileButton.removeFromSuperview()
            }
            
            postsCountLabel.text = "\(user.posts?.count ?? 0)"
            followersCountLabel.text = "\(user.followers?.count ?? 0)"
            followingCountLabel.text = "\(user.following?.count ?? 0)"
            
            healthyButton.backgroundColor = user.isHealthy == true ? .green : .white
            healthyButton.setTitle(user.isHealthy == true ? "Is Healty" : "Not Healty", for: .normal)
            symptomsButton.backgroundColor = user.hasSymptoms == true ? .yellow : .white
            symptomsButton.setTitle(user.hasSymptoms == true ? "Has Symptoms" : "No Symptoms", for: .normal)
            
            positiveButton.backgroundColor = user.isPositive == true ? .red : .white
            positiveButton.setTitle(user.isPositive == true ? "Is Positive" : "Not Positive", for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupColors()
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEditProfile)))
        
        followButton.layer.cornerRadius = 15
        followButton.layer.borderWidth = 1
        
        editProfileButton.layer.cornerRadius = 15
        editProfileButton.layer.borderWidth = 1
        
        positiveButton.layer.cornerRadius = 15
        positiveButton.layer.borderWidth = 1
        
        symptomsButton.layer.cornerRadius = 15
        symptomsButton.layer.borderWidth = 1
        
        healthyButton.layer.cornerRadius = 15
        healthyButton.layer.borderWidth = 1
        
        profileImageView.layer.cornerRadius = 40
        profileImageView.layer.borderWidth = 1
        
        stack(
            profileImageView,
            followButton.withSize(.init(width: 100, height: 28)),
            editProfileButton.withSize(.init(width: 100, height: 28)),
            hstack(stack(postsCountLabel, postsLabel),
                   stack(followersCountLabel, followersLabel),
                   stack(followingCountLabel, followingLabel),
                   spacing: 16, alignment: .center),
            fullNameLabel, bioLabel,
            hstack(healthyButton.withSize(.init(width: 110, height: 28)), symptomsButton.withSize(.init(width: 110, height: 28)), positiveButton.withSize(.init(width: 110, height: 28)), spacing: 16, distribution:.fillEqually),
            spacing: 12,
            alignment: .center
        ).withMargins(.allSides(14))
        
        addSubview(separatorView)
        separatorView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, size: .init(width: 0, height: 0.5))
    }
    
    let separatorView = UIView(backgroundColor: .init(white: 0.4, alpha: 0.3))
    
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setupColors() {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                //Light mode
                postsLabel.textColor = .black
                followersLabel.textColor = .black
                followersCountLabel.textColor = .black
                followingLabel.textColor = .black
                followingCountLabel.textColor = .black
                postsCountLabel.textColor = .black
                bioLabel.textColor = .black
                fullNameLabel.textColor = .black
                
                
            } else {
                //DARK
                postsLabel.textColor = .white
                followersLabel.textColor = .white
                followersCountLabel.textColor = .white
                followingLabel.textColor = .white
                followingCountLabel.textColor = .white
                postsCountLabel.textColor = .white
                bioLabel.textColor = .white
                fullNameLabel.textColor = .white
            }
        } else {
            // Fallback on earlier versions
            postsLabel.textColor = .black
            followersLabel.textColor = .black
            followersCountLabel.textColor = .black
            followingLabel.textColor = .black
            followingCountLabel.textColor = .black
            postsCountLabel.textColor = .black
            bioLabel.textColor = .black
            fullNameLabel.textColor = .black
        }
    }
    
}

