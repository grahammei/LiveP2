//
//  PlayerViewController.swift
//  LiveP2
//
//  Created by PD on 2017/1/23.
//  Copyright © 2017年 PD. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import Photos
import TKSwitcherCollection

class PlayerViewController: UIViewController {
    
    @IBOutlet var superView: UIView!
    @IBOutlet var playerView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var slowButton: TKExchangeSwitch!
    @IBOutlet weak var x3Button: TKExchangeSwitch!
    @IBOutlet weak var fastButton: TKExchangeSwitch!
    @IBOutlet weak var reButton: TKBaseSwitch!
    
 
    var playerAVasset : AVAsset?
    
    var loopCount : Int = 1
    
    var playerRate : Float = 1
    
    var slowInt : Int = 1
    
    var fastInt : Int = 1
    
    var countR : Int = 1
    
    var ok : AVAsset?
    
    var reversePlay : Bool = true
    
    var tempR : Bool = true
    
    var playerQueue : AVQueuePlayer?
    
    var playLooper : AVPlayerLooper?
    
    var playLayer : AVPlayerLayer?
    
    var BLayer = CALayer()
    
    var item : AVPlayerItem?
    
    var tempString : Int = 2
    
    var canCloseN: Bool = false
    
    var finishCon : Bool = true
    
    var LPController : LivePViewController?
    //    var finalVideo : AVAsset?
    var countSave : Int = 0
    
    var FFVideo : AVAsset?
    var FFVideoURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//      reButton.setOn(true, animate: true)
      conButton()
//       reButton.animateDuration = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
      
    }
    
    func conButton() {
        reButton.setOn(false, animate: false)
        slowButton.setOn(false, animate: false)
        fastButton.setOn(false, animate: false)
        x3Button.setOn(false, animate: false)
        reButton.layer.shadowOpacity = 0.3
        reButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        reButton.layer.shadowColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.8).cgColor
        reButton.layer.shadowRadius = 2
        
        slowButton.layer.shadowOpacity = 0.3
        slowButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        slowButton.layer.shadowColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.8).cgColor
        slowButton.layer.shadowRadius = 2
        
        fastButton.layer.shadowOpacity = 0.3
        fastButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        fastButton.layer.shadowColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.8).cgColor
        fastButton.layer.shadowRadius = 2
        
        x3Button.layer.shadowOpacity = 0.3
        x3Button.layer.shadowOffset = CGSize(width: 1, height: 1)
        x3Button.layer.shadowColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.8).cgColor
        x3Button.layer.shadowRadius = 2
    }
   
    func configurePlay() {
        if  playerQueue?.rate != nil {
            reSet()
        }
        if let PAvasset = playerAVasset {
            // 有修改
            var PRate = playerRate
            
            var RPlay = reversePlay
            
            func conREPlay() {
                item = AVPlayerItem(asset: PAvasset)
                playerQueue = AVQueuePlayer(playerItem: item)
                playLayer = AVPlayerLayer(player: playerQueue)
                playerQueue?.isMuted = true
                playerQueue?.actionAtItemEnd = .none
                openNotification()
                
                playerQueue?.play()
                playerQueue?.rate = PRate
                playLayer?.frame = self.playerView.bounds
                playerView.layer.addSublayer(playLayer!)
               
              
            }
            
            func conPlay() {
                item = AVPlayerItem(asset: PAvasset)
                playerQueue = AVQueuePlayer(playerItem: item)
                playLayer = AVPlayerLayer(player: playerQueue)
                playerQueue?.isMuted = true
                playLayer?.frame = self.playerView.bounds
                playLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                playerView.layer.addSublayer(playLayer!)
                playerView.bringSubview(toFront: buttonView)
                playLooper = AVPlayerLooper(player: playerQueue!, templateItem: item!)
                playerQueue?.play()
                playerQueue?.rate = PRate
            }
            
            
            switch RPlay {
            case true :
                conREPlay()
            case false :
                conPlay()
            }
            
//            let CGR = playLayer?.videoRect
//            BLayer.frame = CGR!
//            
//            BLayer.borderColor = UIColor.black.cgColor
//            BLayer.borderWidth = 3
//            playLayer?.addSublayer(BLayer)
            
            playLayer?.shadowOpacity = 1
            playLayer?.shadowOffset = CGSize(width: 2, height: 5)
            playLayer?.shadowColor = UIColor(colorLiteralRed: 0.08, green: 0.08, blue: 0.08, alpha: 1).cgColor
            playLayer?.shadowRadius = 10
            
             superView.bringSubview(toFront: buttonView)
              finishCon = true
        }
    }
    func reSet() {
        playerQueue?.rate = playerRate
        tempR = true
        playLooper = nil
        if self.canCloseN {
            self.closeNotification()
        }
        // playerQueue?.pause()
        playLayer?.removeFromSuperlayer()
    }
    
    
    func openNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.playerDidReachEndNotificationHandler(_:)), name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: item)
        canCloseN = true
        
    }
    
    func closeNotification()  {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: item)
        canCloseN = false
    }
    
    func playerDidReachEndNotificationHandler(_ notification: Notification) {
        let itemDurTime : CMTime = (item!.duration)
        let itemDurTimeS = CMTimeGetSeconds(itemDurTime) - 0.000003
        
        let itemFinalTime : CMTime = CMTime(value: CMTimeValue(itemDurTimeS) , timescale: 1)
        let itemZero : CMTime = CMTime(value: 1, timescale: 2)
        
      //  print(itemDurTime)
        if tempR {
            playerQueue?.seek(to: itemFinalTime)
            
            playerQueue?.rate = -playerRate
            
            tempR = false
        } else {
            playerQueue?.seek(to: itemZero )
            
            playerQueue?.rate = playerRate
            
            tempR = true
        }
    }
    
    
    //MARK: - Save Video
    func getfinalVideo(RE : Bool , avasset : AVAsset!, slowInt : Int64, fastInt : Int32, count : Int) {
        
        //        var FFVideo = FFVideo
        //        var FFVideoURL = FFVideoURL
        //        let date = Date()
        //        let timeFormatter = DateFormatter()
        //        timeFormatter.dateFormat = "yyyy-mm-dd'at'hh:mm:ss.sss"
        //        let strNowTime = timeFormatter.string(from: date) as String
        FFVideo = avasset
        
        var FFvideo1 : AVAsset?
        var tempCount : Int = 1
        let documentsDirectory = NSTemporaryDirectory()
        let aurl = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("1reversedMov3.mov")
        var tempCanCom : Bool = false
        
        func ComVideo() {
            if  let firstVideo = FFVideo {
                
                let duration = firstVideo.duration
                
                let composition = AVMutableComposition()
                //合并视频、音频轨道
                //            let firstTrack = composition.addMutableTrack(
                //                withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
                
                let firstVideoT = firstVideo.tracks(withMediaType: AVMediaTypeVideo)[0]
                var isFirstVideoPortrait = false
                let firstTransform = firstVideoT.preferredTransform
                if firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0) {
                    isFirstVideoPortrait = true
                }
                
                let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
                
                var insertTime: CMTime = kCMTimeZero
                
                for _ in 1...count {
                    do {   try  compositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, duration), of: (firstVideo.tracks(withMediaType: AVMediaTypeVideo)[0]), at: insertTime)
                    }
                    catch {
                    }
                    insertTime = CMTimeAdd(insertTime, duration)
                }
                
                if isFirstVideoPortrait {
                    compositionTrack.preferredTransform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
                }
                
                let comTime = composition.duration
                compositionTrack.scaleTimeRange(CMTimeRangeMake(kCMTimeZero , comTime), toDuration: CMTimeMake(comTime.value * slowInt , comTime.timescale * fastInt))
                
                //                let cache = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
                //                let filePath = cache?.appendingFormat("7mergeVideo-%d.mov", arc4random() % 1000)
               let documentsDirectory1 = NSTemporaryDirectory()
                var filePath = documentsDirectory1.appending(String(tempString-1)+"okMov3.mov")
                let manager = FileManager()
                if manager.fileExists(atPath: filePath) {
                   try! manager.removeItem(atPath: filePath) }
               
                tempString = tempString + 1
              
               filePath = documentsDirectory1.appending(String(tempString)+"okMov3.mov")
                
                let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
                exporter!.outputURL = URL(fileURLWithPath: filePath)
                exporter!.outputFileType = AVFileTypeMPEG4 //AVFileTypeQuickTimeMovie
                //   exporter!.shouldOptimizeForNetworkUse=true
                exporter!.exportAsynchronously(completionHandler: {
                    switch exporter!.status{
                    case  AVAssetExportSessionStatus.failed:
                        if self.countSave < 5 {
                            self.getfinalVideo(RE: RE, avasset: avasset, slowInt: slowInt, fastInt: fastInt, count: count)
                            self.countSave = self.countSave + 1
                            print("failed \(exporter!.error)")
                        }
                        print("failed \(exporter!.error)")
                    case AVAssetExportSessionStatus.cancelled:
                        print("cancelled \(exporter!.error)")
                    default:
                        self.FFVideo = AVAsset(url: (exporter?.outputURL)!)
                        self.FFVideoURL = exporter?.outputURL
                       
                        print("complete1")
                        DispatchQueue.main.async {
                            self.LPController?.naView?.stopAnimating()
                            self.LPController?.naSuperView?.isHidden = true
                            self.actionActivity()
                            print(RE,slowInt,fastInt,count)
                        }
                    }
                    
                })
            }
        }
        
        func RcomVideo(reav : AVAsset!) {
            if  let firstVideo = FFVideo, let secondVideo = reav {
                
                let firstVideoTrack = firstVideo.tracks(withMediaType: AVMediaTypeVideo)[0] as AVAssetTrack
                
                let secondVideoTrack = secondVideo.tracks(withMediaType: AVMediaTypeVideo)[0] as AVAssetTrack
                
                let firstDuration = firstVideoTrack.timeRange.duration
                let secondDuration = secondVideoTrack.timeRange.duration
                
                let composition = AVMutableComposition()
                //合并视频、音频轨道
                //            let firstTrack = composition.addMutableTrack(
                //                withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
                
                let firstVideoT = firstVideo.tracks(withMediaType: AVMediaTypeVideo)[0]
                var isFirstVideoPortrait = false
                let firstTransform = firstVideoT.preferredTransform
                if firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0) {
                    isFirstVideoPortrait = true
                }
                
                let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
                
                
                var insertTime: CMTime = kCMTimeZero
                
                for _ in 1...count {
                    do {
                        
                        try  compositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstDuration), of: (firstVideoTrack), at: insertTime)
                        
                        insertTime = CMTimeAdd(insertTime, firstDuration)
                        
                        
                        try  compositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondDuration), of: (secondVideoTrack), at: insertTime)
                        
                        
                        insertTime = CMTimeAdd(insertTime, secondDuration)
                        
                    }
                    catch {
                    }
                    
                    
                }
                
                if isFirstVideoPortrait {
                    compositionTrack.preferredTransform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
                }
                
                let comTime = composition.duration
                compositionTrack.scaleTimeRange(CMTimeRangeMake(kCMTimeZero , comTime), toDuration: CMTimeMake(comTime.value * slowInt , comTime.timescale * fastInt))
                
                
                //                let cache = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
                //                let filePath = cache?.appendingFormat("7mergeVideo-%d.mov", arc4random() % 1000)
                let documentsDirectory1 = NSTemporaryDirectory()
                var filePath = documentsDirectory1.appending(String(tempString-1)+"okMov3.mov")
                let manager = FileManager()
                if manager.fileExists(atPath: filePath) {
                    try! manager.removeItem(atPath: filePath) }
                
                tempString = tempString + 1
                filePath = documentsDirectory1.appending(String(tempString)+"okMov3.mov")
                let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
                exporter!.outputURL = URL(fileURLWithPath: filePath)
                exporter!.outputFileType = AVFileTypeMPEG4 //AVFileTypeQuickTimeMovie
                //   exporter!.shouldOptimizeForNetworkUse=true
                //                exporter?.timeRange = CMTimeRangeMake(
                //                    kCMTimeZero,insertTime)
                
                exporter!.exportAsynchronously(completionHandler: {
                    switch exporter!.status{
                    case  AVAssetExportSessionStatus.failed:
                        if self.countSave < 5 {
                            self.getfinalVideo(RE: RE, avasset: avasset, slowInt: slowInt, fastInt: fastInt, count: count)
                            self.countSave = self.countSave + 1
                            print("failed \(exporter!.error)")
                        }
                        print("failed \(exporter!.error)")
                    case AVAssetExportSessionStatus.cancelled:
                        print("cancelled \(exporter!.error)")
                    default:
                        self.FFVideo = AVAsset(url: (exporter?.outputURL)!)
                        self.FFVideoURL = exporter?.outputURL
                     
                        print("complete1")
                        DispatchQueue.main.async {
                            self.LPController?.naView?.stopAnimating()
                            self.LPController?.naSuperView?.isHidden = true
                            self.actionActivity()
                            print(RE,slowInt,fastInt,count)
                        }
                    }
                })
            }
        }
        switch RE {
        case true:
         _ =  FFVideo?.reversedAsset(aurl) {
                ree in
                RcomVideo(reav: ree)
            }
        default:
            ComVideo()
        }
    }
    
    func getShareVideoURL()  {
        
        getfinalVideo(RE: reversePlay, avasset: playerAVasset, slowInt: Int64(slowInt), fastInt: Int32(fastInt), count: countR)
        
    }
    
    @IBAction func ReSwitch(_ sender: TKExchangeSwitch) {
        if finishCon {
            finishCon = false
            switch self.reButton.isOn {                
            case true:
                self.reversePlay = !self.reversePlay
                self.configurePlay()
            default:
                self.reversePlay = !self.reversePlay
                self.configurePlay()
            }
        }
      
    }
    @IBAction func SlowSwitch(_ sender: TKExchangeSwitch) {
        if finishCon {
            finishCon = false
            if fastButton.isOn {
                fastButton.changeValue()
            }
        switch slowButton.isOn {
        case false:
            slowInt = 3
            playerRate = 0.67
            fastInt = 1
            configurePlay()
           
        default:
            slowInt = 1
            playerRate = 1
            fastInt = 1
            configurePlay()
        }
           
        }


    }
    @IBAction func FastSwitch(_ sender: TKExchangeSwitch) {
        if finishCon {
            finishCon = false
            if slowButton.isOn {
                slowButton.changeValue()
            }
            switch fastButton.isOn {
            case false:
                slowInt = 1
                playerRate = 2

                fastInt = 2
                configurePlay()
                print(playerRate)
            default:
                slowInt = 1
                playerRate = 1
                fastInt = 1
                configurePlay()
                print(playerRate)
            }
           
        }
        
//
//        
//        if fastInt == 1 {
//            fastInt = 2
//            
//            playerRate = 2
//        } else {
//            fastInt = 1
//            
//            playerRate = 1
//        }
//        slowInt = 1
//        
//        configurePlay()

    }

    @IBAction func X3Switch(_ sender: TKExchangeSwitch) {
        switch x3Button.isOn {
        case false:
            countR = 3
            print("kai",countR)
        default:
            countR = 1
            print("guan",countR)
        }
//        if countR == 1 {
//            countR = 3
//        } else {
//            countR = 1
//        }
    }
   
    @IBAction func TapPlayViewAction(_ sender: UITapGestureRecognizer) {
        LPController?.conNaView()
        LPController?.naView?.startAnimating()
        DispatchQueue.main.async {
             self.getShareVideoURL()
        }
       
    }

    
    func actionActivity() {
        if let nsd  = self.FFVideoURL {
            
            let shareItems:Array = [ (nsd as NSURL) ] as [Any]
            let activityController = UIActivityViewController(activityItems:shareItems, applicationActivities: nil)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityController.popoverPresentationController?.sourceView = self.view
            }
            
            self.present(activityController, animated: true,completion: {
                self.countSave = 0
                self.FFVideoURL = nil
                self.FFVideo = nil
                self.tempString = self.tempString + 1
            })
        }
    }
   
  

    

    
   
   
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
