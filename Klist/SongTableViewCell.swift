//
//  SongTableViewCell.swift
//  Klist
//
//  Created by NGO HO Anh Khoa on 5/19/15.
//  Copyright (c) 2015 NGO HO Anh Khoa. All rights reserved.
//

import UIKit
import Cartography

//Class defines How to display a Cell-Song in TableView (SongListViewController SearchListViewController and LovedListViewController)

class SongTableViewCell: UITableViewCell {

    @IBOutlet var _id_lb: UILabel!
    
    @IBOutlet var vol_lb: UILabel!
    
    @IBOutlet var songname_lb: UILabel!
    
    @IBOutlet var songlyric_lb: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(hex: "#C65A6C")
    }
    
    func setupLayoutSongCell() {
        layout(_id_lb, songname_lb, vol_lb) { id_lb, songname_lb, vol_lb
            in
            id_lb.left == id_lb.superview!.left + 10
            id_lb.top == id_lb.superview!.top + 3
            id_lb.width == 75
            
            songname_lb.left == id_lb.right + 10
            songname_lb.top == songname_lb.superview!.top + 2
            songname_lb.right == songname_lb.superview!.right - 2
            
            vol_lb.left == vol_lb.superview!.left + 10
            vol_lb.top == id_lb.bottom + 2
            vol_lb.width == 75
        }
        
        layout(songname_lb, vol_lb, songlyric_lb ) { songname_lb, vol_lb, songlyric_lb
            in
            
            songlyric_lb.left == songname_lb.left
            songlyric_lb.top == vol_lb.top
            songlyric_lb.right == songlyric_lb.superview!.right - 2
        }
        
    }
    
}




