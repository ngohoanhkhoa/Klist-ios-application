//
//  GenreTableViewCell.swift
//  Klist
//
//  Created by NGO HO Anh Khoa on 5/21/15.
//  Copyright (c) 2015 NGO HO Anh Khoa. All rights reserved.
//

import UIKit
import Cartography

//Class defines How to display a Cell-Genre in TableView (GenreListViewController)

class VolTableViewCell: UITableViewCell {
    
    @IBOutlet var vol_lb: UILabel!
    
    func setupLayoutVolCell() {
        layout(vol_lb) { vol_lb in
            vol_lb.height == 40
            vol_lb.width == vol_lb.superview!.width - 20
            vol_lb.centerY == vol_lb.superview!.centerY
            vol_lb.left == vol_lb.superview!.left + 10
        }
    }
    
}
