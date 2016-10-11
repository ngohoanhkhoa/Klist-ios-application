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

class GenreTableViewCell: UITableViewCell {
    
    @IBOutlet var genre_lb: UILabel!
    func setupLayoutGenreCell() {
        layout(genre_lb ) { genre_lb in
            genre_lb.height == 40
            genre_lb.width == genre_lb.superview!.width
            genre_lb.centerY == genre_lb.superview!.centerY
            genre_lb.left == genre_lb.superview!.left + 10
        }
    }

}
