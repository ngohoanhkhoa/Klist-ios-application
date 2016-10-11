//
//  CommonUtils.swift
//  KList
//
//  Created by Nguyen Duy Linh on 6/21/15.
//  Copyright (c) 2015 NinePoints Co. Ltd. All rights reserved.
//

import Foundation
import Realm

let USE_TYPE_ARIRANG = "USE_TYPE_ARIRANG"
let USE_TYPE_CALI    = "USE_TYPE_CALI"

func getDatabsePath() -> String {
    return RLMRealm.defaultRealmPath()
}

/**
 * Return true if user is using Arirang Karaoke
 * Note: user can change by changing setting
 */
func isUseArirang() -> Bool {
    if (NSUserDefaults.standardUserDefaults().objectForKey(USE_TYPE_ARIRANG) == nil) {
        //default for first installation.
        return true
    }
    
    return NSUserDefaults.standardUserDefaults().boolForKey(USE_TYPE_ARIRANG)
}

/**
 * Return true if user is using Cali Karaoke
 * Note: user can change by changing setting
 */
func isUseCali() -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey(USE_TYPE_CALI)
}

/**
 * Return the maximum volume of database
 */
func getMaxVol(production: Int) -> Int {
    let results = Song.objectsWithPredicate(NSPredicate(format: "production == \(production)")).sortedResultsUsingProperty("vol", ascending: false)
    if (results.count > 0) {
        let song = results[0] as! Song
        return song.vol
    }
    
    return 0
}
