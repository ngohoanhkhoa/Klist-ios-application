//
//  Song.swift
//  Klist
//
//  Created by NGO HO Anh Khoa on 5/14/15.
//  Copyright (c) 2015 NGO HO Anh Khoa. All rights reserved.
//

import Foundation
import Realm

class Song: RLMObject {
    dynamic var _id : Int = 0
    dynamic var songname = ""
    dynamic var songnameclear = ""
    dynamic var production: Int = 0
    dynamic var songlanguage = ""
    dynamic var songlyric = ""
    dynamic var songlyricclear = ""
    dynamic var songauthor = ""
    dynamic var songauthorclear = ""
    dynamic var vol : Int = 0
    dynamic var genre = ""
    dynamic var genreclear = ""
    dynamic var nct_id = ""
    dynamic var youtube = ""
    dynamic var is_like: Int = 0

    override static func primaryKey() -> String? {
        return "_id"
    }
}
