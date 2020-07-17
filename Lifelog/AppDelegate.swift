//
//  AppDelegate.swift
//  FirebaseDemo
//
//  Created by Simon Ng on 14/12/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        if Status.shared.jsonData != nil || Status.shared.remoteStarted{
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            let switchVC = SwitchVC()
//            if let ovc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController(){
//                switchVC.shellVC = ovc // the first ViewController
//            }
//            self.window?.rootViewController = switchVC
//            self.window?.makeKeyAndVisible()
//        }
        // Set up the style and color of the common UI elements
        customizeUIStyle()
        // 設置 Firebase
        FirebaseApp.configure()
        // Configure Facebook Login
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        // 設置 Google 登入
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func applicationWillResignActive(_ application: UIApplication) {
        
//        guard let fun = FunVCSingleton else{
//            return
//        }
//        fun.stopBackGroundUrlCheck()
//        fun.stopProgFetch()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
//        if let lastPresentUrl = MainWebView?.url{
//            PresentingURL = lastPresentUrl
//        }
//        AppDuringUsage = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
//
//        AppDuringUsage = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
//        application.applicationIconBadgeNumber = 0
//        if DidReceiveMemoryWarningBackground && PresentingURL != nil{
//            MainWebView?.load(URLRequest(url: PresentingURL!))
//            print("Trig WebView reload due to MemoryWarning")
//            DidReceiveMemoryWarningBackground = false
//        }
//        guard let fun = FunVCSingleton else{
//            return
//        }
//        fun.startBackgroundUrlCheck()
//        fun.startProgFetch()
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
//        print("didReciveMemoryWarning, AppDuringUsage = ",AppDuringUsage)
//        if !AppDuringUsage{DidReceiveMemoryWarningBackground = true}
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled: Bool
        if url.absoluteString.contains("fb") {
            handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        }else{
            handled = GIDSignIn.sharedInstance().handle(url)
        }
        return handled
    }
    
}
extension AppDelegate {
    func customizeUIStyle() {
        
        // Customize Navigation bar items
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir", size: 16)!, NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)
    }
}
