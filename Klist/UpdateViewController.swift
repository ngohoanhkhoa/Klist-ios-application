//
//  UpdateViewController.swift
//  Klist
//
//  Created by NGO HO Anh Khoa on 5/28/15.
//  Copyright (c) 2015 NinePoints Co. Ltd. All rights reserved.
//

import UIKit
import Realm
import Cartography
import Alamofire

//Class for Loading Database. It is displayed for the first time.

class UpdateViewController: UIViewController {
    
    var progressBar: KYCircularProgress!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var downloadDesc: UILabel!
    @IBOutlet weak var makeInLabel: UILabel!
    @IBOutlet weak var downloadPercent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressBar()
        setupLayout()
    }
    
    override func viewDidAppear(animated: Bool) {
        startDownload()
    }
    
    func startDownload() {
        let tmpPath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        let tmpFile = tmpPath.URLByAppendingPathComponent("tblsong.realm.gz")
        NSFileManager.defaultManager().removeItemAtURL(tmpFile, error: nil)
        Alamofire.download(Method.GET, DB_URL, { _ in tmpFile })
            .progress {
                (_, totalByteRead, totalBytesExpected) in
                dispatch_async(dispatch_get_main_queue()) {
                    let progress = Double(Float(totalByteRead) / Float(totalBytesExpected))
                    self.progressBar.progress = progress
                }
            }.response {
                (request, response, _, error) in
                if (error == nil) {
                    let file = NSData(contentsOfURL: tmpFile);
                    let targetFile = getDatabsePath() as String;
                    let data: NSData = file!.gunzippedData()!;
                    data.writeToFile(targetFile, atomically: true);
                    NSFileManager.defaultManager().removeItemAtURL(tmpFile, error: nil)
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstlaunch1.0")                    
                    
                    self.performSegueWithIdentifier("DownloadToMain", sender: self)
                }
        }

    }
    
    func setupLayout() {
        layout(backgroundImage) { v1 in
            v1.edges == v1.superview!.edges
        }
        
        layout(progressBar, downloadPercent, downloadLabel) { v1, v2, v3 in
            v1.centerX == v1.superview!.centerX
            v2.centerX == v1.centerX
            v3.centerX == v1.centerX
            v1.width == v1.superview!.width
            
            v2.top == v1.top + 170
            v3.top == v1.top + 220
        }
        
        layout(downloadLabel, downloadDesc, makeInLabel) { v1, v2, v3 in
            v2.width == v2.superview!.width - 20
            v2.top == v1.bottom + 50
            v2.centerX == v2.superview!.centerX
            
            v3.bottom == v3.superview!.bottom - 20
            v3.centerX == v3.superview!.centerX
        }
    }
    
    func setupProgressBar() {
        let frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height / 2)
        progressBar = KYCircularProgress(frame: frame)
        
        progressBar.colors = [UIColor(rgba: 0xA6E39DAA), UIColor(rgba: 0xAEC1E3AA), UIColor(rgba: 0xAEC1E3AA), UIColor(rgba: 0xF3C0ABAA)]
        progressBar.lineWidth = 4.0
        progressBar.showProgressGuide = true
        progressBar.progressGuideColor = UIColor(hex: "#C2463A")
        progressBar.progressChangedClosure({ (progress: Double, circularView: KYCircularProgress) in
            self.downloadPercent.text = "\(Int(progress * 100.0))%"
        })
        
        self.view.addSubview(progressBar)
        
        let centerPoint = CGPoint(x:progressBar.frame.width / 2, y: 200.0)
        progressBar.path = UIBezierPath(arcCenter: centerPoint, radius: CGFloat(frame.width / 3), startAngle: CGFloat(M_PI), endAngle: CGFloat(0.0), clockwise: true)
    }
    
}
