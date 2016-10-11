//
//  GenreListViewController.swift
//  Klist
//
//  Created by NGO HO Anh Khoa on 5/21/15.
//  Copyright (c) 2015 NGO HO Anh Khoa. All rights reserved.
//

import UIKit
import Realm
import Cartography

class GenreListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var background_iv: UIImageView!
    @IBOutlet var genreTitle_lb: UILabel!
    @IBOutlet var back_btn: UIButton!
    @IBOutlet weak var allButton: MKButton!
    @IBOutlet weak var okButton: MKButton!
    @IBOutlet var tableView: UITableView!

    var arrayGenre: RLMResults!
    var arrayGenreSelected = [String]()
    var allGenres = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let realm = RLMRealm.defaultRealm()
        arrayGenre = Genre.allObjects().sortedResultsUsingProperty("nameClear", ascending: true)
        
        for s in arrayGenre {
            let g = s as! Genre
            allGenres.append(g.nameClear)
        }
        
        if (arrayGenreSelected.count <= 0 || arrayGenreSelected.count == allGenres.count) {
            arrayGenreSelected = allGenres
            allButton.setTitle("Bỏ chọn tất cả", forState: .Normal)
            allButton.tag = 0
        } else {
            allButton.tag = 1
            allButton.setTitle("Chọn tất cả", forState: .Normal)
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        setupInterface()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(arrayGenre.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! GenreTableViewCell
        let object = arrayGenre[UInt(indexPath.row)] as! Genre
        cell.genre_lb.text = object.name
        cell.setupLayoutGenreCell()
        cell.backgroundColor = UIColor.clearColor()
        
        if (hasSelected(object.nameClear)) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    //Select a cell - a song
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {        
        let cell = tableView.cellForRowAtIndexPath(indexPath)as! GenreTableViewCell
        
        let genre = arrayGenre[UInt(indexPath.row)] as! Genre
        if (hasSelected(genre.nameClear)) {
            cell.accessoryType = UITableViewCellAccessoryType.None
            removeSelected(genre.nameClear)
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            arrayGenreSelected.append(genre.nameClear)
        }
        
        cell.selected = false
    }

    func setupLayout() {
        layout(view) { v in
            v.width == v.superview!.width - 60
            v.height == v.superview!.height - 110
            v.centerX == v.superview!.centerX
            v.centerY == v.superview!.centerY
        }
        
        layout(genreTitle_lb, tableView, back_btn ) { genreTitle_lb, tableView, back_btn
            in
            
            genreTitle_lb.width == genreTitle_lb.superview!.width
            genreTitle_lb.height == 40
            genreTitle_lb.centerX == genreTitle_lb.superview!.centerX
            genreTitle_lb.top == genreTitle_lb.superview!.top
            
            tableView.top == genreTitle_lb.bottom + 5
            tableView.width == tableView.superview!.width
            tableView.bottom == tableView.superview!.bottom - 50
            tableView.centerX == tableView.superview!.centerX
            
            back_btn.bottom == back_btn.superview!.bottom
            back_btn.left == back_btn.superview!.left
            back_btn.height == 40
            back_btn.width == back_btn.superview!.width / 3
        }
        
        layout(back_btn, allButton, okButton) { v1, v2, v3 in
            v2.width == v1.width
            v2.height == v1.height
            v2.centerX == v2.superview!.centerX
            v2.centerY == v1.centerY
            
            v3.width == v1.width
            v3.height == v1.height
            v3.right == v3.superview!.right
            v3.centerY == v1.centerY
        }
    }
    
    func setupInterface() {
        tableView.backgroundColor = UIColor.clearColor()
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        SwiftEventBus.post("PopupClosed")
        closeAll()
    }
    
    @IBAction func allButtonAction(sender: MKButton) {
        if (sender.tag == 0) {
            sender.tag = 1
            arrayGenreSelected = [String]()
            sender.setTitle("Chọn tất cả", forState: .Normal)
        } else {
            sender.tag = 0
            arrayGenreSelected = allGenres
            sender.setTitle("Bỏ chọn tất cả", forState: .Normal)
        }
        tableView.reloadData()

    }
    @IBAction func okButtonAction(sender: AnyObject) {
        if (arrayGenreSelected.count == allGenres.count) {
            SwiftEventBus.post("FilterByGenre", userInfo: ["genres": []])
        } else {
            SwiftEventBus.post("FilterByGenre", userInfo: ["genres": arrayGenreSelected])
        }
        SwiftEventBus.post("PopupClosed")
        closeAll()

    }
    
    func closeAll() {
        self.view.removeFromSuperview();
        removeFromParentViewController()
    }
    
    func hasSelected(value: String) -> Bool {
        for v in arrayGenreSelected {
            if (v == value) {
                return true
            }
        }
        
        return false
    }
    
    func removeSelected(value: String) {
        for (index, v) in enumerate(arrayGenreSelected) {
            if (v == value) {
                arrayGenreSelected.removeAtIndex(index)
                return
            }
        }
    }

}
