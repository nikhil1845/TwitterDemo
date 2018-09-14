//
//  ViewController.swift
//  twitterDemo
//
//  Created by SEPL MAC on 11/09/18.
//  Copyright © 2018 nik MAC. All rights reserved.
//

import UIKit
import TwitterKit
import Alamofire

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "TwitterDemo"

        FHSTwitterEngine.shared().permanentlySetConsumerKey("Sh4JYw4aQ773emLJTL9zlFFF2", andSecret: "KYZk6x2O0HO8e1ClUyqDDMjXOnYJhjwHBXrY4PJ6M7OFBxkE7z")
        FHSTwitterEngine.shared().loadAccessToken()

    }
    override func viewWillAppear(_ animated: Bool) {
        if !NetworkReachabilityManager()!.isReachable //check for internet reachability and inform user
        {
            let alert = UIAlertController(title: "Check", message: "Please Check Internet Connection", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    @IBAction func twitterLogin(_ sender: Any) {
 
        let loginController = FHSTwitterEngine.shared().loginController { (success) -> Void in
            
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                var controller1 = storyboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
            
                                DispatchQueue.main.async(execute:
                                {
                                    self.navigationController?.pushViewController(controller1, animated: true)
                                })
            

            
            } as UIViewController
        self .present(loginController, animated: true, completion: nil)
    }
}

