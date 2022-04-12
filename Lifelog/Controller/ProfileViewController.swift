//
//  ProfileViewController.swift
//  FirebaseDemo
//
//  Created by user on 2020/5/19.


import UIKit
import Firebase
import GoogleSignIn
import Kingfisher
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var myPhoto: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureUI() {
        self.title = "My Profile"
        myPhoto.clipsToBounds = true
        myPhoto.layer.cornerRadius = (myPhoto.frame.width) / 2
        
        if let currentUser = Auth.auth().currentUser {
            nameLabel.text = currentUser.displayName
            if let urls = currentUser.photoURL{
                myPhoto.kf.setImage(with: urls)
            }else{
                myPhoto.image = UIImage(named: "icon_nopic")
            }
            countLabel.text = "\(photoCount ?? 0) photos"
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logout(sender: UIButton) {
        do {
            if let providerData = Auth.auth().currentUser?.providerData {
                let userInfo = providerData[0]
                switch userInfo.providerID {
                case "google.com":
                    GIDSignIn.sharedInstance.signOut()
                default:
                    break
                }
            }
            try Auth.auth().signOut()
            
        } catch {
            let alertController = UIAlertController(title: "Logout Error", message: error.localizedDescription, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        // Present the welcome view
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeView") {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}
