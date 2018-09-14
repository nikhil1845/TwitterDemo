//
//  friendsDetailsView.swift
//  twitterDemo
//
//  Created by SEPL MAC on 14/09/18.
//  Copyright © 2018 nik MAC. All rights reserved.
//

import UIKit

class friendsDetailsView: UIView {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenLabel: UILabel!
    @IBOutlet weak var blurView: UIView!
    var userDetails : NSDictionary = [:]
    
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
      
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        
        

        if let screenName = userDetails["screen_name"] as? String //use if let instead of Forced Unwrapping
        {
            screenLabel.text = "@" + screenName
            let profile_image_url_https = FHSTwitterEngine.shared().getProfileImageURLString(forUsername: userDetails["screen_name"] as? String, andSize: FHSTwitterEngineImageSizeOriginal) as! String
            
             profileImageView.sd_setImage(with: URL(string: profile_image_url_https ), placeholderImage: UIImage(named: "placeholdersmall.jpg"))
        
        }
        if let followers_count = userDetails["followers_count"] as? NSNumber
        {
            followersCount.text = "\(followers_count)"
        }
        if let friends_count = userDetails["friends_count"] as? NSNumber
        {
            followingCount.text = "\(friends_count)"

        }
        
        let gestureSwift2AndHigher = UITapGestureRecognizer(target: self, action:#selector (self.removeblurDidTapped (_:)))
        blurView.addGestureRecognizer(gestureSwift2AndHigher)

        
    }
    @objc func removeblurDidTapped(_ sender:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
            self.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.layoutIfNeeded()    //layoutIfneeded so Autolayout constraints will rearrange the subviews according to new frame

        }, completion: { finished in
            print("Napkins opened!")
            self.removeFromSuperview()
        })
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
