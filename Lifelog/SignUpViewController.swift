//
//  SignUpViewController.swift
//  FirebaseDemo
//
//  Created by Simon Ng on 5/1/2017.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit
import Firebase
class SignUpViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Sign Up"
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func registerAccount(_ sender: UIButton) {
        // 輸入驗證
        guard let name = nameTextField.text, name != "",
            let emailAddress = emailTextField.text, emailAddress != "", let password = passwordTextField.text, password != "" else {
                
                let alertConteoller = UIAlertController(title: "Registration Error", message: "Please make sure you provide your name, email address and password to com plete the registration.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertConteoller.addAction(okayAction)
                present(alertConteoller, animated: true, completion: nil)
                return
        }
        // 在 Firebase 註冊使用者帳號
        Auth.auth().createUser(withEmail: emailAddress, password: password, completion : { (user, error) in
            if let error = error{
                let alertController = UIAlertController(title: "Registration Error", message: error.localizedDescription , preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true,completion: nil)
                return
            }
            
            // 儲存使用者的名稱
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(){
                changeRequest.displayName = name
                changeRequest.commitChanges(completion: {(error) in
                    if let error = error{
                        print("Failed to change the display name: \(error.localizedDescription)")
                    }
                })
            }
            // 移除鍵盤
            self.view.endEditing(true)
            
            // 傳送認證信
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                print("Failed to send verification email")
            })
            
            let alertController = UIAlertController(title: "Email Verification", message: "We've just sent a confirmation email to your email address. Please check your inbox and click the verification link in that email to complete the sign up.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                // 呈現主視圖
                //            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView"){
                //                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        })
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
