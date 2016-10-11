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

class SearchListViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {
    
    @IBOutlet var background_iv: UIImageView!
    @IBOutlet var searchInfo_lb: UILabel!
    @IBOutlet var searchSongBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tabViewBarItem: UITabBarItem!
    var searchResults: RLMResults!
    
    // SegmentedControl for Language (All - EN - VN)
    @IBOutlet var language_segmentedControl: UISegmentedControl!
    var notificationToken: RLMNotificationToken?
    var searchTextScroll = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        language_segmentedControl.hidden = true
        tableView.hidden = true
        searchInfo_lb.hidden = false
        
        //Loading data - Begin
        
        let realm = RLMRealm.defaultRealm()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        notificationToken = RLMRealm.defaultRealm().addNotificationBlock { [unowned self] note, realm in
            self.tableView.reloadData()
        }
        setupLayout()
        setupInterface()
    }
    
    //Open/Close Keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    //Click Search in Keyboard
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sr = searchResults {
            return Int(searchResults.count)
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SongTableViewCell
        
        if let sr = searchResults {
            let object = sr[UInt(indexPath.row)] as! Song
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
        }

        return cell;
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    //SearchBar
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text.isEmpty{
            language_segmentedControl.hidden = true
            searchInfo_lb.hidden = false
            tableView.hidden = true
        } else {
            language_segmentedControl.hidden = false
            tableView.hidden = false
            searchInfo_lb.hidden = true
            
            getSearchResults(searchText)
            searchTextScroll = searchText
        }
        tableView.reloadData()
    }
    
    //Swipe to left - Like/DoNotLike a song - Begin
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        let realm = RLMRealm.defaultRealm()
        let object = searchResults[UInt(indexPath.row)] as! Song
 
        var editButton = UITableViewRowAction(style: .Default, title: "Thích", handler: { (action, indexPath) in
            self.tableView.dataSource?.tableView?(
                self.tableView,
                commitEditingStyle: .Insert,
                forRowAtIndexPath: indexPath
            )
            
            return
        })
        
        if object.is_like == 1 {
            editButton = UITableViewRowAction(style: .Default, title: "Không Thích", handler: { (action, indexPath) in
                self.tableView.dataSource?.tableView?(
                    self.tableView,
                    commitEditingStyle: .Delete,
                    forRowAtIndexPath: indexPath
                )
                
                return
            })
        }
        
        if object.is_like == 1 {
            editButton.backgroundColor = UIColor(red: 102/255, green: 0, blue: 51/255, alpha: 0.5)
        } else {
            editButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.4)
        }
        
        return [editButton]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Insert) {
            
            let realm = RLMRealm.defaultRealm()
            let object = searchResults[UInt(indexPath.row)] as! Song
            
            realm.beginWriteTransaction()
            object.is_like = 1
            realm.commitWriteTransaction()
        }
        
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let realm = RLMRealm.defaultRealm()
            let object = searchResults[UInt(indexPath.row)] as! Song
            
            realm.beginWriteTransaction()
            object.is_like = 0
            realm.commitWriteTransaction()
            
        }
    }
    
    //Swipe to left - Like/DoNotLike a song - End
    
    //Goto SongContentViewController with song searched
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let indexPath : NSIndexPath = self.tableView.indexPathForSelectedRow()!
        let object = searchResults[UInt(indexPath.row)] as! Song
        
        if segue.identifier == "ShowContentSearchSong"
        {
            if let destinationVC = segue.destinationViewController as? SongContentViewController {
                
                destinationVC.songObject = object
            }
        }
    }
    
    // Function for Getting Searched Results with KeyWords (searchText)/ SegmentedControl
    
    func getSearchResults(searchText: String) {
        var searchResultText: String
        
        searchResultText = dropFirst(searchText)
        var predicate : NSPredicate!
        
        predicate = NSPredicate(format: "songnameclear CONTAINS [c]%@ OR songauthorclear CONTAINS [c]%@", searchText, searchText)
        
        if searchText.toInt() != nil {
            var number = searchText.toInt()!
            if distance(searchText.startIndex, searchText.endIndex) == 1 {
                predicate = NSPredicate(format: "songnameclear CONTAINS [c]%@ OR songauthorclear CONTAINS [c]%@ OR _id >= %d OR _id >= %d", searchText, searchText, number*10000, number*100000)}
            if distance(searchText.startIndex, searchText.endIndex) == 2 {
                predicate = NSPredicate(format: "songnameclear CONTAINS [c]%@ OR songauthorclear CONTAINS [c]%@ OR _id >= %d OR _id >= %d", searchText, searchText, number*1000, number*10000)}
            if distance(searchText.startIndex, searchText.endIndex) == 3 {
                predicate = NSPredicate(format: "songnameclear CONTAINS [c]%@ OR songauthorclear CONTAINS [c]%@ OR _id >= %d OR _id >= %d", searchText, searchText, number*100, number*1000)}
            if distance(searchText.startIndex, searchText.endIndex) == 4 {
                predicate = NSPredicate(format: "songnameclear CONTAINS [c]%@ OR songauthorclear CONTAINS [c]%@ OR _id >= %d OR _id >= %d", searchText, searchText, number*10, number*100)}
            if distance(searchText.startIndex, searchText.endIndex) == 5 {
                predicate = NSPredicate(format: "songnameclear CONTAINS [c]%@ OR songauthorclear CONTAINS [c]%@ OR _id = %d OR _id >= %d", searchText, searchText, number, number*10)}
            if distance(searchText.startIndex, searchText.endIndex) == 6 {
                predicate = NSPredicate(format: "songnameclear CONTAINS [c]%@ OR songauthorclear CONTAINS [c]%@ OR _id = %d", searchText, searchText, number)}
        } else if distance(searchText.startIndex, searchText.endIndex) > 1 && searchText[searchText.startIndex] == "#" {
            if(searchResultText.toInt() != nil) {
                var number = searchResultText.toInt()!
                if distance(searchResultText.startIndex, searchResultText.endIndex) == 1 {
                    predicate = NSPredicate(format: "_id >= %d OR _id >= %d", number*10000, number*100000)}
                if distance(searchResultText.startIndex, searchResultText.endIndex) == 2 {
                    predicate = NSPredicate(format: "_id >= %d OR _id >= %d", number*1000, number*10000)}
                if distance(searchResultText.startIndex, searchResultText.endIndex) == 3 {
                    predicate = NSPredicate(format: "_id >= %d OR _id >= %d", number*100, number*1000)}
                if distance(searchResultText.startIndex, searchResultText.endIndex) == 4 {
                    predicate = NSPredicate(format: "_id >= %d OR _id >= %d", number*10, number*100)}
                if distance(searchResultText.startIndex, searchResultText.endIndex) == 5 {
                    predicate = NSPredicate(format: "_id = %d OR _id >= %d", number, number*10)}
                if distance(searchResultText.startIndex, searchResultText.endIndex) == 6 {
                    predicate = NSPredicate(format: "_id = %d", number)}
            }
        } else if(searchText[searchText.startIndex] == "@") {
            predicate = NSPredicate(format: "songauthorclear CONTAINS [c]%@", searchResultText)
        } else if(searchText[searchText.startIndex] == "*") {
            predicate = NSPredicate(format: "songlyricclear CONTAINS [c]%@", searchResultText)
        } else if(searchText[searchText.startIndex] == "$") {
            predicate = NSPredicate(format: "songnameclear CONTAINS [c]%@", searchResultText)
        }
        
        var predicates: [NSPredicate] = [predicate]
        if isUseArirang() {
            predicates.append(NSPredicate(format: "production == 1"))
        } else {
            predicates.append(NSPredicate(format: "production == 2"))
        }
        
        if language_segmentedControl.selectedSegmentIndex ==  0 {
            predicates.append(NSPredicate(format: "songlanguage CONTAINS 'vn' "))
        } else if language_segmentedControl.selectedSegmentIndex == 1 {
            predicates.append(NSPredicate(format: "songlanguage = 'en' "))
            searchResults = searchResults.objectsWithPredicate(predicate).sortedResultsUsingProperty("_id", ascending: true)
        } else if language_segmentedControl.selectedSegmentIndex == 2 {
            predicates.append(NSPredicate(format: "songlanguage CONTAINS '' "))
        }
        
        searchResults = Song.objectsWithPredicate(NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicates)).sortedResultsUsingProperty("_id", ascending: true)
    }
    
    func setupLayout() {
        layout(searchSongBar,language_segmentedControl,tableView) { searchSongBar, language_segmentedControl, tableView
            in
            searchSongBar.width == searchSongBar.superview!.width - 10
            searchSongBar.height == 40
            searchSongBar.centerX == searchSongBar.superview!.centerX
            searchSongBar.top == searchSongBar.superview!.top + 20
            
            language_segmentedControl.top == searchSongBar.bottom + 2
            language_segmentedControl.width == searchSongBar.superview!.width - 10
            language_segmentedControl.centerX == language_segmentedControl.superview!.centerX
            
            
            tableView.top == language_segmentedControl.bottom + 5
            tableView.width == searchSongBar.superview!.width
            tableView.centerX == tableView.superview!.centerX
            tableView.bottom == tableView.superview!.bottom - 50
            
        }
        
        layout(searchSongBar, searchInfo_lb) { searchSongBar, searchInfo_lb
            in
            searchInfo_lb.width == searchInfo_lb.superview!.width - 20
            searchInfo_lb.centerX == searchInfo_lb.superview!.centerX
            searchInfo_lb.bottom <= searchInfo_lb.superview!.bottom + 50
            searchInfo_lb.top == searchSongBar.bottom + 2
        }
        
        layout(background_iv) { v in
            v.edges == v.superview!.edges
        }
    }
    
    func setupInterface() {
        background_iv.image = UIImage(named: "bg")
        searchInfo_lb.textColor = UIColor.whiteColor()
        tableView.backgroundColor = UIColor.clearColor()
        var textColorSearchBar = searchSongBar.valueForKey("searchField") as? UITextField
        textColorSearchBar?.textColor = UIColor.whiteColor()
    }
    
    @IBAction func language_segmentedControl(sender: AnyObject) {
        getSearchResults(searchTextScroll)
        tableView.reloadData()
    }
}
