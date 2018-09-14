//
//  UserDetailsViewController.swift
//  twitterDemo
//
//  Created by SEPL MAC on 11/09/18.
//  Copyright © 2018 nik MAC. All rights reserved.
//

import UIKit
import TwitterKit
import SDWebImage
import Alamofire

class UserDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var userProfile : TWTRUser?
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    var nextCurser = "-1"
    var currentType = 0   //0 for followers 1 for following
    var users = NSMutableArray()
    
    // MARK: - ControllerLifeCycleStarted

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        
        setUpNavBar()

        if let username = FHSTwitterEngine.shared().authenticatedUsername //use if let instead of Forced Unwrapping
        {
            screenName.text = "@" + username
            print("username",username)
            
            let profileImageUrl = FHSTwitterEngine.shared().getProfileImageURLString(forUsername: username, andSize: FHSTwitterEngineImageSizeOriginal) as! String
            
            print("imgurl=",profileImageUrl )
            profileImageView.sd_setImage(with: URL(string: profileImageUrl ), placeholderImage: UIImage(named: "placeholder.jpg"))

        }
        
       
        
        let verifyCredentials = FHSTwitterEngine.shared().verifyCredentials() as! NSDictionary
        print("verifyCredentials=",verifyCredentials)
 
        if let FollowersIDs = FHSTwitterEngine.shared().getFollowersIDs() as? NSDictionary
        {
            if let Followers = FollowersIDs["ids"] as? NSArray
            {
                print("Followers_count",Followers.count)
                followersCount.text = "\(Followers.count)"
            }
            
        }
        
        
        if let FriendsIDs = FHSTwitterEngine.shared().getFriendsIDs() as? NSDictionary
        {
            if let following = FriendsIDs["ids"] as? NSArray
            {
                print("following Friends",following.count)
                followingCount.text = "\(following.count)"
            }
            
        }
        
        print("session = ",FHSTwitterEngine.shared().isAuthorized())
        
        reloadData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if !NetworkReachabilityManager()!.isReachable  //check for internet reachability and inform user
        {
            let alert = UIAlertController(title: "Check", message: "Please Check Internet Connection", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    func setUpNavBar()  {
        self.navigationItem.setHidesBackButton(true, animated: false)

        let logoutButton = UIBarButtonItem(image: UIImage(named: "logout.png"), style: .plain, target: self, action: #selector (self.logoutAction))
       
        let tweetimage : UIImage? = UIImage.init(named: "Twitter.png")!.withRenderingMode(.alwaysOriginal)
        let tweetButton = UIBarButtonItem(image: tweetimage, style: .plain, target: self, action: #selector (self.btnPostTweetClicked(sender:)))

        self.navigationItem.rightBarButtonItem  = logoutButton
        self.navigationItem.leftBarButtonItem  = tweetButton
 
        self.title = "TwitterDemo"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Server Calls

    func reloadData()
    {
        DispatchQueue.global(qos: .background).async {
        //background code
        
        let userid = FHSTwitterEngine.shared().authenticatedID
        var list : NSDictionary?
        
        if(self.currentType == 0)  // on the basis of current type flag slect the appropriate list type
        {
            list = FHSTwitterEngine.shared().listFriends(forUser: userid, isID: true, withCursor: self.nextCurser) as? NSDictionary
//            print("listFriends",list)
        }else
        {
            list = FHSTwitterEngine.shared().listFollowers(forUser: userid, isID: true, withCursor: self.nextCurser) as? NSDictionary
//            print("listFollowers",list)
        }
        
        if let tmpList = list
        {
            if let usersArray = tmpList["users"] as? [Any]
            {
                self.users.addObjects(from: usersArray)
                self.nextCurser =  tmpList["next_cursor_str"] as! String
                DispatchQueue.main.async {
                    //your main thread
                    self.mainTableView.reloadData()

                }
            }
        }
            
        }
        
    }
    // MARK: - UitableViewDelegate and dataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! friendsCell
        let user = users[indexPath.row] as! NSDictionary
        cell.userName.text = user["name"] as! String
        cell.profileImage.sd_setImage(with: URL(string: user["profile_image_url_https"] as! String ), placeholderImage: UIImage(named: "placeholdersmall.jpg"))

        print(user)
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
 
        if indexPath.row + 1 == users.count
        {
            reloadData()    //load more data as soon as user reached last cell
        }
        if nextCurser != "0"
        {
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            tableView.tableFooterView = spinner
            tableView.tableFooterView?.isHidden = false

        }
        else
        {
            tableView.tableFooterView?.isHidden = true
            tableView.tableFooterView = nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row] as! NSDictionary
        let friendDetailsView = Bundle.main.loadNibNamed("friendsDetails", owner: nil, options: nil)![0] as! friendsDetailsView //load module
        friendDetailsView.userDetails = user //assign selected user dictionary to module property "userDetails"
        
        
        //animate and add sub module or view
        
        friendDetailsView.frame = CGRect(x: 0, y: 0, width: 0, height: 0) //set the starting frame
        friendDetailsView.center = view.center
        view.addSubview(friendDetailsView)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            friendDetailsView.frame = self.view.frame                   //set the final frame
            friendDetailsView.layoutIfNeeded()                          //layoutIfneeded so Autolayout constraints will rearrange the subviews according to new frame
        }, completion: { finished in
            

            print("details opened!")
        })
 
    }
    
    // MARK: - IBActions

    @IBAction func followingDidTapped(_ sender: UIButton)
    {
        currentType = 0
        sender.superview?.backgroundColor = UIColor.lightGray
        followersButton.superview?.backgroundColor = UIColor.clear
        users.removeAllObjects()
        nextCurser = "-1"
        mainTableView.reloadData()

        reloadData()
    }
    
    @IBAction func followerDidTapped(_ sender: UIButton) {
        currentType = 1
        sender.superview?.backgroundColor = UIColor.lightGray
        followingButton.superview?.backgroundColor = UIColor.clear
        users.removeAllObjects()
        nextCurser = "-1"
        mainTableView.reloadData()

        reloadData()
    }
    @objc func logoutAction()  {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to LogOut?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                /////on okey
                URLCache.shared.removeAllCachedResponses()
                URLCache.shared.diskCapacity = 0
                URLCache.shared.memoryCapacity = 0
                FHSTwitterEngine.shared().clearAccessToken()
                self.navigationController?.popViewController(animated: true)
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
       
    }
    @objc func btnPostTweetClicked(sender: AnyObject)
    {
        let alert = UIAlertController(title: "Tweet", message: "Write a tweet below.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Write a tweet here..." })
        alert.addAction(UIAlertAction(title: "Post", style: .default, handler:
            { action in
                var title = String()
                var message = String()
                let textField = alert.textFields![0] as UITextField
                let result = FHSTwitterEngine.shared() .postTweet(textField.text!)
                
                if(result != nil)
                {
                    title = "Error"
                    message = "error occured while poting"
                }
                else
                {
                    title = "Success"
                    message = "Successfully posted."
                }
                let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
                self.present(alertView, animated: true, completion: nil)
                
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


