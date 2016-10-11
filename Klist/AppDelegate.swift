//
//  AppDelegate.swift
//  Klist
//
//  Created by NGO HO Anh Khoa on 5/14/15.
//  Copyright (c) 2015 NGO HO Anh Khoa. All rights reserved.
//

import UIKit
import Realm
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            
        if shouldShowDownload() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootController = storyboard.instantiateViewControllerWithIdentifier("UpdateViewController") as! UpdateViewController
            if self.window != nil {
                self.window!.rootViewController = rootController
            }
        }
        
        UITabBar.appearance().tintColor = UIColor.whiteColor();
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(hex: "#B8989A")], forState: UIControlState.Normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(hex: "#BC5859")], forState: UIControlState.Selected)

        return true        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func shouldShowDownload() -> Bool {
        let db = getDatabsePath()
        if (!NSFileManager.defaultManager().fileExistsAtPath(db)
            || !NSUserDefaults.standardUserDefaults().boolForKey("firstlaunch1.0"))  {
            return true
        }
        
        return false
    }

    func updateDatabase() {
        let vol = getMaxVol(1)
        let url = UPDATE_URL + "\(vol + 1)"
        
        SwiftEventBus.post("StartUpdateDB")
        JLToast.makeText("Bắt đầu cập nhật dữ liệu.", duration: 2.seconds).show()
        Alamofire.request(.GET, url)
            .responseJSON { (_, _, JSON, _) in
                let array = JSON as! [NSDictionary]
                
                let realm = RLMRealm.defaultRealm()
                realm.beginWriteTransaction()
                var count: Int = 0
                for j:NSDictionary in array {
                    let song = Song()
                    song._id = (j["sid"] as! NSNumber).integerValue;
                    song.songname = j["songname"] as! String
                    song.songnameclear = j["songnameclear"] as! String
                    song.production = (j["production"] as! NSNumber).integerValue;
                    song.songlanguage = j["songlanguage"] as! String;
                    song.songlyric = j["songlyric"] as! String;
                    song.songlyricclear = j["songlyricclear"] as! String;
                    song.songauthor = j["songauthor"] as! String;
                    song.songauthorclear = j["songauthorclear"] as! String;
                    song.vol = (j["vol"] as! NSNumber).integerValue;
                    song.genre = j["genre"] as! String;
                    song.genreclear = j["genreclear"] as! String;
                    song.is_like = 0;
                    if let nct: AnyObject = j["nct_id"] {
                        song.nct_id = (nct as! String);
                    } else {
                        song.nct_id = ""
                    }

                    Song.createOrUpdateInRealm(realm, withValue: song)
                    count++
                }
                realm.commitWriteTransaction()                
                SwiftEventBus.postToMainThread("CompleteUpdateDB", userInfo: ["total": count])
                if (count > 0) {
                    JLToast.makeText("Cập nhật dữ liệu xong. \(count) bài hát được cập nhật.", duration: 2.seconds).show()
                } else {
                    JLToast.makeText("Cập nhật dữ liệu xong. Không có bài hát mới.", duration: 2.seconds).show()
                }
            }
    }
}

