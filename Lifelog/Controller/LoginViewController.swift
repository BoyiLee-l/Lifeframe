//
//  LogonViewController.swift
//  FirebaseDemo
//
//  Created by user on 2020/5/19.


import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Log In"
        emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = ""
    }
    
    @IBAction func login(sender: UIButton) {
        // 輸入驗證
        guard let emailAddress = emailTextField.text, emailAddress != "",
              let password = passwordTextField.text, password != "" else {
                  let alertController = UIAlertController(title: "Login Error", message: "Both fields must not be blank.", preferredStyle: .alert)
                  let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                  alertController.addAction(okayAction)
                  present(alertController, animated: true, completion: nil)
                  return
              }
        
        // 呼叫 Firebase APIs 執行登入
        Auth.auth().signIn(withEmail: emailAddress, password: password, completion: { (result, error) in
            if let error = error {
                let alertController = UIAlertController(title: "Login Error", message:
                                                            error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            // Email 認證
            guard let result = result, result.user.isEmailVerified else {
                let alertController = UIAlertController(title: "Login Error", message: "You haven't confirmed your email address yet. We sent you a confirmation email wh en you sign up. Please click the verification link in that email. If you need us t o send the confirmation email again, please tap Resend Email.", preferredStyle: .alert)
                
                let okayAction = UIAlertAction(title: "Resend email", style: .default, handler: { (action) in
                    Auth.auth().currentUser?.sendEmailVerification(completion: nil) })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }

            // 解除鍵盤
            self.view.endEditing(true)
            
            // 呈現主視圖
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView"){
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}
