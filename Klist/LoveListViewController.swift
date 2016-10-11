//
//  LoveListViewController.swift
//  Klist
//
//  Created by NGO HO Anh Khoa on 5/20/15.
//  Copyright (c) 2015 NGO HO Anh Khoa. All rights reserved.
//

import UIKit
import Realm
import Cartography

class LoveListViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var background_iv: UIImageView!
    @IBOutlet var klistTitle_lb: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var language_segmentedControl: UISegmentedControl!
    
    var array: RLMResults!
    var notificationToken: RLMNotificationToken?
    var indexLovedScroll = 0
    var languageScroll = 0
    
    @IBAction func language_segmentedControl(sender: AnyObject) {
        var language = NSPredicate(format: "songlanguage CONTAINS ''")
        if sender.selectedSegmentIndex == 0 {
            language = NSPredicate(format: "songlanguage CONTAINS 'vn'")
            languageScroll = 1
        } else if sender.selectedSegmentIndex == 1 {
            language = NSPredicate(format: "songlanguage CONTAINS 'en'")
            languageScroll = 1
        } else if sender.selectedSegmentIndex == 2 {
            language = NSPredicate(format: "songlanguage CONTAINS ''")
            languageScroll = 2
        }
        
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [NSPredicate(format: "is_like = 1"), language])
        array = Song.objectsWithPredicate(predicate).sortedResultsUsingProperty("_id", ascending: true)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let language = NSPredicate(format: "songlanguage == 'vn'")
        let like = NSPredicate(format: "is_like = 1")
        array = Song.objectsWithPredicate(NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [like, language])).sortedResultsUsingProperty("songnameclear", ascending: true)
        
        let realm = RLMRealm.defaultRealm()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register notification for monitoring data change
        notificationToken = RLMRealm.defaultRealm().addNotificationBlock { [unowned self] note, realm in
            self.tableView.reloadData()
        }
        
        if indexLovedScroll > 5 {
            let indexPath = NSIndexPath(forRow: indexLovedScroll, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            indexLovedScroll = 0
        }
  
        setupLayout()
        setupInterface()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(array!.count)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SongTableViewCell
        let object:Song = array[UInt(indexPath.row)] as! Song
        
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
    
    //Goto SongContentViewController with song selected
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let indexPath : NSIndexPath = self.tableView.indexPathForSelectedRow()!
        let object = array[UInt(indexPath.row)] as! Song
        
        if segue.identifier == "ShowContentLoveSong"
        {
            if let destinationVC = segue.destinationViewController as? SongContentViewController {
                destinationVC.songObject = object
            }
        }
    }
    
    //Swipe to left - DoNotLike a song - Begin
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var deleteButton = UITableViewRowAction(style: .Default, title: "Không thích", handler: { (action, indexPath) in
            self.tableView.dataSource?.tableView?(
                self.tableView,
                commitEditingStyle: .Delete,
                forRowAtIndexPath: indexPath
            )
            
            return
        })
        
        deleteButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.4)
        
        return [deleteButton]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let realm = RLMRealm.defaultRealm()
            
            let song = array[UInt(indexPath.row)] as! Song

            realm.beginWriteTransaction()
            song.is_like = 0
            realm.commitWriteTransaction()
            tableView.reloadData()            
        }
    }
    
    //Swipe to left - DoNotLike a song - End
    
    func setupLayout() {
        //Layout - Begin
        
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
        layout(background_iv) { v
            in
            v.edges == v.superview!.edges
        }
        
        //Layout - End
    }
    
    func setupInterface() {
        background_iv.image = UIImage(named: "bg")
        klistTitle_lb.backgroundColor = UIColor.clearColor()
        tableView.backgroundColor = UIColor.clearColor()
    }
}
