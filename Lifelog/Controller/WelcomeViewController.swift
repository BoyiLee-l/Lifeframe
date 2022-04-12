//
//  WelcomeViewController.swift
//  FirebaseDemo
//
//  Created by user on 2020/5/19.


import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class WelcomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func unwindtoWelcomeView(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: google登入
    @IBAction func googleLogin(sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        let configuration = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            } else {
                guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                    return
                }
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
                
                Auth.auth().signIn(with: credential){ (result, error) in
                    if let error = error{
                        print("Login error: \(error.localizedDescription)")
                        let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(okayAction)
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    
                    // 呈現主視圖
                    if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView"){
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //MARK: 臉書登入
    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (
            result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            // 呼叫 Firebase APIs 來執行登入
            Auth.auth().signIn(with: credential, completion: { (result, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                // 呈現主視圖
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
}
