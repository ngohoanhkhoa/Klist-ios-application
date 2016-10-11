//
//  TabViewController.swift
//  Klist
//
//  Created by NGO HO Anh Khoa on 5/19/15.
//  Copyright (c) 2015 NGO HO Anh Khoa. All rights reserved.
//

import UIKit

//Class TabViewController for transfering data between ViewControllers (SongListViewController, LoveListViewController, SearchListViewController, GenreListviewController)

class TabViewController: UITabBarController, UITabBarControllerDelegate {
    
//    // Locate the song which is selected.
//    var indexSongScroll = 0
//    var indexSearchScroll = 0
//    var indexLovedScroll = 0
//    var languageScroll = 0
//    
//    // String contains Value for Searching Songs
//    var searchTextScroll = ""
//    
//    // Values about Song Genre
//    var isGenreSelected = false
//    var arrayGenreSelected = [String]()
//    //Values about Song Vol
//    var isVolSelected = false
//    var arrayVolSelected = [Int]()
//    
    override func viewDidAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = self
    }
}
