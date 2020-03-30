//
//  TrackerController.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/30/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import LBTATools
import Alamofire



class trackerCell: LBTAListCell<User> {
    
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
    
    override var item: User! {
        didSet {
            fullNameLabel.text = item.fullName
            profileImageView.sd_setImage(with: URL(string: item.profileImageUrl ?? ""))
        }
    }
}

class TrackerController: LBTAListController<trackerCell, User> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Positive"
        setupActivityIndicatorView()
        fetchLikes()
    }
    
    fileprivate func fetchLikes() {
        let url = "\(Service.shared.baseUrl)/positives"
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                self.activityIndicatorView.stopAnimating()
                guard let data = dataResp.data else { return }
                
                do {
                    let users = try JSONDecoder().decode([User].self, from: data)
                    self.items = users
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
    
    func countDown(post: Post){
        print("CREATEDAT: ", post.createdAt)
        
        
        let calendar = Calendar.current

        let components = calendar.dateComponents([.hour, .minute, .month, .year, .day], from: post.createdAt as Date)

        let currentDate = calendar.date(from: components)!

        let userCalendar = Calendar.current

        // here we set the due date. When the timer is supposed to finish
        let competitionDate = NSDateComponents()
        competitionDate.day = 14
        userCalendar.date(byAdding: competitionDate as DateComponents, to: currentDate)

        let competitionDay = userCalendar.date(byAdding: competitionDate as DateComponents, to: currentDate)!

        //here we change the seconds to hours,minutes and days
        let CompetitionDayDifference = calendar.dateComponents([.day, .hour, .minute], from: post.createdAt, to: competitionDay)


        //finally, here we set the variable to our remaining time
        let daysLeft = CompetitionDayDifference.day
        let hoursLeft = CompetitionDayDifference.hour
        let minutesLeft = CompetitionDayDifference.minute

        print("day:", daysLeft ?? "N/A", "hour:", hoursLeft ?? "N/A", "minute:", minutesLeft ?? "N/A")

        //Set countdown label text
        print("\(daysLeft ?? 0) Days, \(hoursLeft ?? 0) Hours, \(minutesLeft ?? 0) Minutes")
    }
    
}

extension TrackerController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

