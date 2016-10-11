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

class VolListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var background_iv: UIImageView!
    @IBOutlet var volTitle_lb: UILabel!
    @IBOutlet var back_btn: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    var arrayVol = [Int]()
    var arrayVolSelected = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = RLMRealm.defaultRealm()
        
        var predicate : NSPredicate!
        if isUseArirang() {
            predicate = NSPredicate(format: "vol != 0 AND production == 1 AND songlanguage == 'vn'")
        } else {
            predicate = NSPredicate(format: "vol != 0 AND production == 2")
        }
        let begin = Song.objectsWithPredicate(predicate).sortedResultsUsingProperty("vol", ascending: true)
        var start = 0
        var stop = 0
        if (begin.count > 0) {
            start = (begin[0] as! Song).vol
        }
        let end = Song.objectsWithPredicate(predicate).sortedResultsUsingProperty("vol", ascending: false)
        if (end.count > 0) {
            stop = (end[0] as! Song).vol
        }
        for v in start...stop {
            arrayVol.append(v)
        }
  
        if (arrayVolSelected.count <= 0 || arrayVolSelected.count == arrayVol.count) {
            arrayVolSelected = arrayVol
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
        return arrayVol.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! VolTableViewCell
        let vol = arrayVol[indexPath.row] as Int
        cell.vol_lb.text = "Vol \(vol)"
        cell.setupLayoutVolCell()        
        cell.backgroundColor = UIColor.clearColor()
        
        if (hasSelected(vol)) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    //Select a cell - a song
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! VolTableViewCell
        let vol = arrayVol[indexPath.row] as Int
        if (hasSelected(vol)) {
            cell.accessoryType = UITableViewCellAccessoryType.None
            removeSelected(vol)
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            arrayVolSelected.append(vol)
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
        
        layout(volTitle_lb, tableView, back_btn ) { genreTitle_lb, tableView, back_btn
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
    
    @IBAction func okButtonAction(sender: AnyObject) {
        if (arrayVolSelected.count == arrayVol.count) {
            SwiftEventBus.post("FilterByVol", userInfo: ["vols": []])
        } else {
            SwiftEventBus.post("FilterByVol", userInfo: ["vols": arrayVolSelected])
        }
        SwiftEventBus.post("PopupClosed")
        closeAll()
    }
    
    @IBAction func allButtonAction(sender: MKButton) {
        if (sender.tag == 0) {
            sender.tag = 1
            arrayVolSelected = [Int]()
            sender.setTitle("Chọn tất cả", forState: .Normal)
        } else {
            sender.tag = 0
            arrayVolSelected = arrayVol
            sender.setTitle("Bỏ chọn tất cả", forState: .Normal)
        }
        tableView.reloadData()
    }

    @IBAction func backBtnAction(sender: AnyObject) {
        SwiftEventBus.post("PopupClosed")
        closeAll()
    }
    
    func closeAll() {
        self.view.removeFromSuperview();
        removeFromParentViewController()
    }
    
    func hasSelected(value: Int) -> Bool {
        for v in arrayVolSelected {
            if (v == value) {
                return true;
            }
        }
        
        return false;
    }
    
    func removeSelected(value: Int) {
        for (index, v) in enumerate(arrayVolSelected) {
            if (v == value) {
                arrayVolSelected.removeAtIndex(index)
                return
            }
        }
    }
}
