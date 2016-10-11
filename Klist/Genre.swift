//
//  Genre.swift
//  KList
//
//  Created by Nguyen Duy Linh on 7/1/15.
//  Copyright (c) 2015 NinePoints Co. Ltd. All rights reserved.
//

import Foundation
import Realm

class Genre: RLMObject {
    dynamic var name = ""
    dynamic var nameClear = ""
    
    override static func primaryKey() -> String? {
        return "nameClear"
    }
}
