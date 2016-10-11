//
//  SongContentViewController.swift
//  Klist
//
//  Created by NGO HO Anh Khoa on 5/18/15.
//  Copyright (c) 2015 NGO HO Anh Khoa. All rights reserved.
//

import UIKit
import Realm
import AVFoundation
import Cartography
import Alamofire
import XCDYouTubeKit

// Class displays Content of a Song.

class SongContentViewController: UIViewController {
    
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var songNumber: UILabel!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songAuthor: UILabel!
    @IBOutlet weak var songLyric: UITextView!
    
    @IBOutlet weak var playContainer: UIView!
    @IBOutlet weak var playProgress: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var karaButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var songId = 0
    var songObject: Song?
    var audioPlayer: AVPlayer?
    var observer: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupInterface()
    }
    
    func playSong() {
        let nctId = songObject!.nct_id as String;
        if nctId != "" && nctId != "FAILED" {
            let url = "http://www.nhaccuatui.com/download/song/\(nctId)"
            Alamofire.request(.GET, url)
                .responseJSON { (_, _, JSON, error) in
                    if (error == nil) {
                        let result = JSON as! NSDictionary
                        let success = result["error_message"] as! String
                        if (success == "Success") {
                            let data = result["data"] as! NSDictionary
                            let url = data["stream_url"] as! String
                            if let soundPath = NSURL(string: url) {
                                AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
                                AVAudioSession.sharedInstance().setActive(true, error: nil)
                            
                                self.audioPlayer = AVPlayer(URL: soundPath)
                                self.audioPlayer?.play()
                                self.setupObserver()
                            }
                        }
                    } else {
                        println(error)
                        JLToast.makeText("Không thể phát nhạc lúc này. Vui lòng kiểm tra kết nối mạng.", duration: 2.seconds)
                    }
                }
        }
    }
    
    func setupLayout() {
        layout(backgroundImage, headerView, playContainer) { v1, v2, v3 in
            v1.edges == v1.superview!.edges
            
            v2.width == v2.superview!.width
            v2.top == v2.top
            v2.centerX == v2.superview!.centerX
            v2.height == 64
            
            v3.height == 50
            v3.width == v3.superview!.width
            v3.centerX == v3.superview!.centerX
            v3.bottom == v3.superview!.bottom
        }
        
        layout(titleLabel, backButton, heartButton) { t, b, h in
            t.width == t.superview!.width
            t.centerX == t.superview!.centerX
            t.top == t.superview!.top + 20
            t.height == 44
            
            b.centerY == t.centerY
            b.left == b.superview!.left + 10
            b.height == 40
            b.width == 70
            
            h.centerY == t.centerY
            h.right == h.superview!.right - 10
            h.height == 40
            h.width == 40
        }
        
        layout(songNumber, songName, songAuthor) { v1, v2, v3 in
            v1.top == v1.superview!.top + 74
            v1.width == v1.superview!.width
            v1.centerX == v1.superview!.centerX
            
            v2.width == v1.width
            v2.top == v1.bottom + 5
            v2.centerX == v1.centerX
            
            v3.width == v2.width
            v3.top == v2.bottom + 5
            v3.centerX == v2.centerX
        }
        
        layout(songAuthor, songLyric) { v1, v2 in
            v2.top == v1.bottom + 5
            v2.width == v2.superview!.width - 20
            v2.bottom == v2.superview!.bottom - 60 ~ 20
            v2.centerX == v2.superview!.centerX
        }
        
        layout(playButton, karaButton, timeLabel) { v1, v2, v3 in
            v1.height == 40
            v1.width == 40
            v1.centerX == v1.superview!.centerX
            v1.centerY == v1.superview!.centerY
            
            v2.height == 40
            v2.width == 40
            v2.left == v1.right + 20
            v2.centerY == v1.centerY
            
            v3.right == v3.superview!.right - 10
            v3.centerY == v2.centerY
        }
        
        layout(playButton, playProgress) { v1, v2 in
            v2.left == v2.superview!.left + 10
            v2.right == v1.left - 20
            v2.centerY == v1.centerY
        }
    }
    
    func setupInterface() {
        backgroundImage.image = UIImage(named: "bg")
        songLyric.layer.cornerRadius = 5
        songLyric.backgroundColor = UIColor(hex: "#FFFFFF10")
        
        if (songObject?.nct_id == nil || songObject?.nct_id == "" || songObject?.nct_id == "FAILED") {
            if (songObject?.youtube == "") {
                playContainer.hidden = true
                layout(songLyric) { v1 in
                    v1.bottom == v1.superview!.bottom - 10 ~ 50
                }
            } else {
                playButton.enabled = false
            }
        }
        
        if (songObject?.youtube == "") {
            karaButton.enabled = false
        }
        
        if let s = songObject {
            songNumber.text = String(s._id)
            songName.text = s.songname
            songAuthor.text = s.songauthor
            songLyric.text = s.songlyric
            
            if (s.is_like == 1) {
                heartButton.setImage(UIImage(named: "heart_filled"), forState: .Normal)
            } else {
                heartButton.setImage(UIImage(named: "heart_empty"), forState: .Normal)
            }
            
            if (s.youtube == "") {
                karaButton.hidden = true
            } else {
                karaButton.hidden = false
            }
        }
        
        playProgress.setThumbImage(UIImage(named: "slider"), forState: .Normal)
    }
    
    @IBAction func playButtonAction(sender: MKButton) {
        if (sender.tag == 0) {
            sender.tag = 1
            if audioPlayer?.status == AVPlayerStatus.ReadyToPlay {
                audioPlayer?.play()
                setupObserver()
            } else {
                playSong()
            }
            sender.setImage(UIImage(named: "pause"), forState: .Normal)
        } else {
            sender.tag = 0
            sender.setImage(UIImage(named: "play"), forState: .Normal)
            audioPlayer?.pause()
            clearObserver()
        }
    }
    
    @IBAction func karaButtonAction(sender: AnyObject) {
        pause()
        let videoPlayerVC = XCDYouTubeVideoPlayerViewController(videoIdentifier: songObject?.youtube)
        self.presentMoviePlayerViewControllerAnimated(videoPlayerVC)
    }
    
    @IBAction func playProgressChanged(sender: UISlider) {
        //@TODO: implement me
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        audioPlayer?.pause()
        clearObserver()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func heartButtonAction(sender: AnyObject) {
        if let s = songObject {
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            if s.is_like == 1 {
                s.is_like = 0
                heartButton.setImage(UIImage(named: "heart_empty"), forState: .Normal)
            } else {
                s.is_like = 1
                heartButton.setImage(UIImage(named: "heart_filled"), forState: .Normal)
            }
            realm.commitWriteTransaction()
        }
    }
    
    func setupObserver() {
        self.observer = self.audioPlayer?.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1, 60), queue: dispatch_get_main_queue(), usingBlock: { time in
            let duration: NSTimeInterval = CMTimeGetSeconds(self.audioPlayer!.currentItem.duration)
            
            let currentTime: NSTimeInterval = duration - CMTimeGetSeconds(time)
            let sec: Int = Int(currentTime % 60)
            let min: Int = Int((currentTime / 60) % 60)
            let info = String(format: "%02ld:%02ld", min, sec)
            
            self.timeLabel.text = info
            self.playProgress.minimumValue = 0
            self.playProgress.maximumValue = Float(duration)
            self.playProgress.value = Float(CMTimeGetSeconds(time))
        })
    }
    
    func clearObserver() {
        if (observer != nil) {
            audioPlayer?.removeTimeObserver(observer)
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        playButton.tag = 0
        playButton.setImage(UIImage(named: "play"), forState: .Normal)
        clearObserver()
    }
}

