//
//  SongListViewController.swift
//  Klist
//
//  Created by NGO HO Anh Khoa on 5/18/15.
//  Copyright (c) 2015 NGO HO Anh Khoa. All rights reserved.
//

import UIKit
import Realm
import Cartography

class SongListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet var background_iv: UIImageView!
    @IBOutlet var klistTitle_lb: UILabel!
    @IBOutlet var TabViewBarItem: UITabBarItem!
    @IBOutlet var genre_btn: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var vol_btn: UIButton!
    
    // SegmentedControl for Language (All - EN - VN)
    
    @IBOutlet var language_segmentedControl: UISegmentedControl!
    @IBAction func language_segmentedControl(sender: AnyObject) {
        displaySong()
        tableView.reloadData()
    }
    
    var array: RLMResults!
    var notificationToken: RLMNotificationToken?
    var arrayGenreSelected = [String]()    
    var arrayVolSelected = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = RLMRealm.defaultRealm()
        
        tableView.delegate = self
        tableView.dataSource = self
        displaySong()
        
        notificationToken = RLMRealm.defaultRealm().addNotificationBlock { [unowned self] note, realm in
            self.tableView.reloadData()
        }

        setupLayout()
        setupInterface()
        
        SwiftEventBus.onMainThread(self, name: "KaraokeTypeChanged") { _ in
            self.displaySong()
            self.tableView.reloadData()
        }
        
        SwiftEventBus.onMainThread(self, name: "FilterByVol") { info in
            let selected:[String: [Int]] = info.userInfo as! [String: [Int]]
            self.arrayVolSelected = selected["vols"]!
            self.displaySong()
            self.tableView.reloadData()
        }
        
        SwiftEventBus.onMainThread(self, name: "FilterByGenre") { info in
            let selected:[String: [String]] = info.userInfo as! [String: [String]]
            self.arrayGenreSelected = selected["genres"]!
            self.displaySong()
            self.tableView.reloadData()
        }
        
        SwiftEventBus.onMainThread(self, name: "PopupClosed") { _ in
            self.vol_btn.enabled = true
            self.genre_btn.enabled = true
        }
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(array.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SongTableViewCell
        
        let object = array[UInt(indexPath.row)] as! Song
        cell._id_lb.text = String(object._id)
        cell.songname_lb.text = object.songname
        cell.vol_lb.text = "vol " +  String(object.vol)
        cell.songlyric_lb.text = object.songlyric
        
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor(hex: "#FFFFFF05")
        } else {
            cell.backgroundColor = UIColor(hex: "#FFFFFF10")
        }
        cell.setupLayoutSongCell()
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }

    //Swipe to left - Like/DoNotLike a song - Begin
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        let realm = RLMRealm.defaultRealm()
        let object = array[UInt(indexPath.row)] as! Song
        let attrString = NSAttributedString(
            string: GoogleIcon.e600,
            attributes: NSDictionary(
                object: UIFont(name: GoogleIconName, size: 12.0)!,
                forKey: NSFontAttributeName) as [NSObject : AnyObject])
        
        var editButton: UITableViewRowAction
        
        if (object.is_like == 1) {
            editButton = UITableViewRowAction(style: .Default, title: "Không Thích", handler: { (action, indexPath) in
                self.tableView.dataSource?.tableView?(
                    self.tableView,
                    commitEditingStyle: .Delete,
                    forRowAtIndexPath: indexPath
                )
                
                return
            })
            editButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.4)
        } else {
            editButton = UITableViewRowAction(style: .Normal,title: "Thích", handler: { (action, indexPath) in
                self.tableView.dataSource?.tableView?(
                    self.tableView,
                    commitEditingStyle: .Insert,
                    forRowAtIndexPath: indexPath
                )
                return
            
            })
            editButton.backgroundColor = UIColor(red: 102/255, green: 0, blue: 51/255, alpha: 0.5)
        }
        
        return [editButton]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Insert) {
            let realm = RLMRealm.defaultRealm()
            
            let object = array[UInt(indexPath.row)] as! Song
            realm.beginWriteTransaction()
            object.is_like = 1
            realm.commitWriteTransaction()
            
        } else if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let realm = RLMRealm.defaultRealm()
            
            let object = array[UInt(indexPath.row)] as! Song
            realm.beginWriteTransaction()
            object.is_like = 0
            realm.commitWriteTransaction()
        }
    }

    //Goto SongContentViewController/GenreListViewController/VolListViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowContentSong"
        {
            let indexPath : NSIndexPath = self.tableView.indexPathForSelectedRow()!
            var object = array[UInt(indexPath.row)] as! Song
            
            if let destinationVC = segue.destinationViewController as? SongContentViewController {
                destinationVC.songObject = object
            }
        }
    }
    
    //Function for Displaying Song for Genre/SegmentedControl
    func displaySong() {
        var predicates: [NSPredicate] = []
        if (arrayGenreSelected.count > 0) {
            let genrePredicate = NSPredicate(format: "genreclear IN %@", arrayGenreSelected)
            predicates.append(genrePredicate)
        }
        
        if (arrayVolSelected.count > 0) {
            let volPredicate = NSPredicate(format: "vol IN %@", arrayVolSelected)
            predicates.append(volPredicate)
        }
        
        var langPredicate: NSPredicate?
        switch (language_segmentedControl.selectedSegmentIndex) {
        case 0:
            langPredicate = NSPredicate(format: "songlanguage == 'vn'")
            break
        case 1:
            langPredicate = NSPredicate(format: "songlanguage == 'en'")
            break
        default:
            break
        }

        if isUseArirang() {
            predicates.append(NSPredicate(format: "production == 1"))
        } else {
            predicates.append(NSPredicate(format: "production == 2"))
        }
    
        if let langPredicate = langPredicate {
            predicates.append(langPredicate)
        }
        
        if (predicates.count > 0) {
            array = Song.allObjects().objectsWithPredicate(NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicates)).sortedResultsUsingProperty("songnameclear", ascending: true)
        } else {
            array = Song.allObjects().sortedResultsUsingProperty("songnameclear", ascending: true)
        }
    }
    
    func setupLayout() {
        layout(klistTitle_lb,language_segmentedControl,tableView) { klistTitle_lb, language_segmentedControl, tableView
            in
            klistTitle_lb.width == klistTitle_lb.superview!.width
            klistTitle_lb.height == 40
            klistTitle_lb.centerX == klistTitle_lb.superview!.centerX
            klistTitle_lb.top == klistTitle_lb.superview!.top + 20
            
            language_segmentedControl.top == klistTitle_lb.bottom + 2
            language_segmentedControl.centerX == language_segmentedControl.superview!.centerX
            language_segmentedControl.width == klistTitle_lb.superview!.width - 10
            
            tableView.top == language_segmentedControl.bottom + 5
            tableView.width == klistTitle_lb.superview!.width
            tableView.centerX == tableView.superview!.centerX
            tableView.bottom == tableView.superview!.bottom - 50
        }
        
        layout(klistTitle_lb, genre_btn, vol_btn) { klistTitle_lb, genre_btn, vol_btn
            in
            
            genre_btn.centerY == klistTitle_lb.centerY
            genre_btn.right == klistTitle_lb.right - 10
            genre_btn.height == 35
            genre_btn.width == 44
            
            vol_btn.centerY == klistTitle_lb.centerY
            vol_btn.left == klistTitle_lb.left + 10
            vol_btn.width == 44
            vol_btn.height == 35
            
        }
        
        layout(background_iv) { v
            in
            v.edges == v.superview!.edges
            
        }
    }
    
    func setupInterface() {
        background_iv.image = UIImage(named: "bg")
        klistTitle_lb.backgroundColor = UIColor.clearColor()
        tableView.backgroundColor = UIColor.clearColor()
    }

    @IBAction func volButtonAction(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let volVC = storyboard.instantiateViewControllerWithIdentifier("VolListViewController") as! VolListViewController
        volVC.arrayVolSelected = arrayVolSelected
        self.addChildViewController(volVC)
        self.view.addSubview(volVC.view)
        volVC.view.layer.zPosition += 1
        volVC.setupLayout()
        
        volVC.view.transform = CGAffineTransformMakeTranslation(0, 480)
        UIView.animateWithDuration(0.5) {
            volVC.view.transform = CGAffineTransformIdentity
        }
        
        self.vol_btn.enabled = false
        self.genre_btn.enabled = false
    }
    
    @IBAction func genreButtonAction(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let volVC = storyboard.instantiateViewControllerWithIdentifier("GenreListViewController") as! GenreListViewController
        volVC.arrayGenreSelected = arrayGenreSelected
        self.addChildViewController(volVC)
        self.view.addSubview(volVC.view)
        volVC.view.layer.zPosition += 1
        volVC.setupLayout()
        
        volVC.view.transform = CGAffineTransformMakeTranslation(0, 480)
        UIView.animateWithDuration(0.5) {
            volVC.view.transform = CGAffineTransformIdentity
        }
        
        self.vol_btn.enabled = false
        self.genre_btn.enabled = false

    }
    
}
