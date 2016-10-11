//
//  HelpViewController.swift
//  Klist
//
//  Created by NGO HO Anh Khoa on 6/1/15.
//  Copyright (c) 2015 NinePoints Co. Ltd. All rights reserved.
//

import UIKit
import Realm
import Alamofire
import Cartography

class HelpViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var karaokeListLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var introLabel: UITextView!
    @IBOutlet weak var madeInLabel: UILabel!
    @IBOutlet weak var updateButton: MKButton!
    @IBOutlet weak var aboutTab: UIView!
    @IBOutlet weak var headerBg: UIView!
    
    @IBOutlet weak var setttingTab: UIView!
    @IBOutlet weak var typeHeadingLabel: UILabel!
    @IBOutlet weak var typeArirang: UILabel!
    @IBOutlet weak var typeCali: UILabel!
    @IBOutlet weak var adsHeadingLabel: UILabel!
    @IBOutlet weak var removeAdButton: MKButton!
    @IBOutlet weak var removeAdHintLabel: UILabel!
    @IBOutlet weak var dataHeadingLabel: UILabel!
    @IBOutlet weak var dataArirangLabel: UILabel!
    @IBOutlet weak var dataCaliLabel: UILabel!
    @IBOutlet weak var arirangVolLabel: UILabel!
    @IBOutlet weak var caliVolLabel: UILabel!
    @IBOutlet weak var settingScrollView: UIScrollView!

    var typeArirangSwitch: SevenSwitch!
    var typeCaliSwitch: SevenSwitch!
    
    func setupLayout() {
        layout(bgImage, headerBg) { v1, v2 in
            v1.edges == v1.superview!.edges
            v2.width == v1.width
            v2.top == v1.top
            v2.height == 60
            v2.centerX == v1.centerX
        }
        
        layout(headerLabel, updateButton, segmentControl) { v1, v2, v3 in
            v1.width == v1.superview!.width
            v1.top == v1.superview!.top + 20
            v1.height == 44
            
            v2.height == 35
            v2.width == 44
            v2.top == v1.top + 5
            v2.right == v1.right - 10
            
            v3.width == 225
            v3.height == 29
            v3.top == v1.bottom + 10
            v3.centerX == v3.superview!.centerX
        }
        
        layout(segmentControl, aboutTab, logoButton) { v1, v2, v3 in
            v2.width == v2.superview!.width
            v2.top == v1.bottom + 5
            v2.centerX == v2.superview!.centerX
            v2.bottom == v2.superview!.bottom - 10
            
            v3.centerX == v3.superview!.centerX
            v3.width == 165
            v3.height == 65
            v3.top == v3.superview!.top
        }
        
        layout(karaokeListLabel, versionLabel, introLabel) { v1, v2, v3 in
            v1.width == v1.superview!.width
            v1.centerX == v1.superview!.centerX
            v1.top == v1.superview!.top + 60
            
            v2.top == v1.bottom + 5
            v2.width == v1.width
            v2.centerX == v1.centerX
            
            v3.top == v2.bottom + 5
            v3.width == v2.width - 20
            v3.centerX == v2.centerX
            v3.bottom == v3.superview!.bottom - 75
        }
        
        layout(madeInLabel) { v1 in
            v1.width == v1.superview!.width
            v1.top == v1.superview!.bottom - 65
            v1.centerX == v1.superview!.centerX
        }
    }
    
    func setupLayoutForSettingTab() {
        layout(segmentControl, settingScrollView) { v1, v2 in
            v2.width == v2.superview!.width
            v2.top == v1.bottom + 5
            v2.centerX == v2.superview!.centerX
            v2.bottom == v2.superview!.bottom - 10
        }
        
        layout(view, typeHeadingLabel) { v1, v2 in
            v2.width == v1.width - 20
            v2.centerX == v1.centerX
        }
        
        layout(typeHeadingLabel, typeArirang, typeCali) { v1, v2, v3 in
            v1.top == v1.superview!.top + 35
            
            v2.top == v1.bottom + 5
            v2.width == v1.width
            v2.centerX == v1.centerX
            v2.height == 40
            
            v3.top == v2.bottom + 1
            v3.width == v2.width
            v3.centerX == v2.centerX
            v3.height == 52
        }
        
        layout(typeArirang, typeArirangSwitch) { v1, v2 in
            v2.centerY == v1.centerY
            v2.right == v1.right - 10
            v2.width == 52
            v2.height == 30
        }
        
        layout(typeCali, typeCaliSwitch) { v1, v2 in
            v2.centerY == v1.centerY
            v2.right == v1.right - 10
            v2.width == 52
            v2.height == 30
        }
        
        layout(typeCali, adsHeadingLabel, removeAdButton) { v1, v2, v3 in
            v2.top == v1.bottom + 15
            v2.width == v1.width
            v2.centerX == v1.centerX
            
            v3.top == v2.bottom + 5
            v3.width == v2.width
            v3.centerX == v2.centerX
            v3.height == 40
        }
        
        layout(removeAdButton, removeAdHintLabel, dataHeadingLabel) { v1, v2, v3 in
            v2.width == v1.width
            v2.top == v1.bottom + 5
            v2.centerX == v1.centerX
            
            v3.width == v1.width
            v3.top == v2.bottom + 15
            v3.centerX == v2.centerX
        }
        
        layout(dataHeadingLabel, dataArirangLabel, dataCaliLabel) { v1, v2, v3 in
            v2.top == v1.bottom + 5
            v2.width == v1.width
            v2.centerX == v1.centerX
            v2.height == 40
            
            v3.top == v2.bottom + 1
            v3.width == v1.width
            v3.centerX == v1.centerX
            v3.height == 40
        }
        
        layout(dataArirangLabel, arirangVolLabel) { v1, v2 in
            v2.centerY == v1.centerY
            v2.right == v1.right - 10
        }
        
        layout(dataCaliLabel, caliVolLabel) { v1, v2 in
            v2.centerY == v1.centerY
            v2.right == v1.right - 10
        }
    }
    
    /**
     * Add switchs for choosing karaoke device type
     */
    func setupSwitchs() {
        typeArirangSwitch = SevenSwitch(frame: CGRectZero)
        typeArirangSwitch.thumbTintColor = UIColor(hex: "#09607B")
        typeArirangSwitch.activeColor =  UIColor(red: 0.07, green: 0.09, blue: 0.11, alpha: 1)
        typeArirangSwitch.inactiveColor =  UIColor(hex: "#422435")
        typeArirangSwitch.onTintColor =  UIColor(hex: "#422435")
        typeArirangSwitch.borderColor = UIColor.clearColor()
        typeArirangSwitch.shadowColor = UIColor.clearColor()
        typeArirangSwitch.on = isUseArirang()
        
        typeArirangSwitch.addTarget(self, action: "onKaraokeTypeChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        typeCaliSwitch = SevenSwitch(frame: CGRectZero)
        typeCaliSwitch.thumbTintColor = UIColor(hex: "#09607B")
        typeCaliSwitch.activeColor =  UIColor(red: 0.07, green: 0.09, blue: 0.11, alpha: 1)
        typeCaliSwitch.inactiveColor =  UIColor(hex: "#422435")
        typeCaliSwitch.onTintColor =  UIColor(hex: "#422435")
        typeCaliSwitch.borderColor = UIColor.clearColor()
        typeCaliSwitch.shadowColor = UIColor.clearColor()
        typeCaliSwitch.on = isUseCali()
        
        typeCaliSwitch.addTarget(self, action: "onKaraokeTypeChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        settingScrollView.addSubview(typeArirangSwitch)
        settingScrollView.addSubview(typeCaliSwitch)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSwitchs()
        setupLayout()
        setupLayoutForSettingTab()
        
        settingScrollView.contentSize = CGSizeMake(setttingTab.frame.width, setttingTab.frame.height)
        bgImage.image = UIImage(named: "bg")
        
        //set volume label
        arirangVolLabel.text = "VOL \(getMaxVol(1))"
        caliVolLabel.text = "VOL \(getMaxVol(2))"
        
        updateButton.addTarget(self, action: "onUpdateButton:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    @IBAction func segmentChanaged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            self.settingScrollView.hidden = true
            self.aboutTab.alpha = 0
            UIView.animateWithDuration(0.5.seconds) {
                self.aboutTab.hidden = false
                self.aboutTab.alpha = 1
            }
        } else {
            self.aboutTab.hidden = true
            self.settingScrollView.alpha = 0
            UIView.animateWithDuration(0.5.seconds) {
                self.settingScrollView.hidden = false
                self.settingScrollView.alpha = 1
            }
        }
    }
    
    func onKaraokeTypeChanged(sender: SevenSwitch) {
        if sender == typeCaliSwitch {
            typeArirangSwitch.on = !sender.on
            NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: USE_TYPE_CALI)
            NSUserDefaults.standardUserDefaults().setBool(!sender.on, forKey: USE_TYPE_ARIRANG)
        } else {
            typeCaliSwitch.on = !sender.on
            NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: USE_TYPE_ARIRANG)
            NSUserDefaults.standardUserDefaults().setBool(!sender.on, forKey: USE_TYPE_CALI)
        }
        
        SwiftEventBus.post("KaraokeTypeChanged")
    }
    
    func onUpdateButton(sender: MKButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.updateDatabase()
    }
}
