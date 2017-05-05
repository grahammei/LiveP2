//
//  ViewController.swift
//  LiveP2
//
//  Created by PD on 2017/1/23.
//  Copyright © 2017年 PD. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import SCLAlertView
import NVActivityIndicatorView
import ElasticTransition

class LivePViewController: UIViewController, MenuViewDelegate {
    
    @IBOutlet var superView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var touchView: UIView!
    
    let WarningTitle = "Excure me"
    let Subtitle = "You've no LivePhoto OR No Authorization . Go to take some LivePhoto . Try again"
    
    var transition = ElasticTransition()
    let lgr = UIScreenEdgePanGestureRecognizer()
    
    let segueMenu : String = "MenuSegue"
    
    let seguePlayer : String = "PlayerContainer"
    
    let segueImage : String = "ImageArray"
    
    var indexPatchViewModelImage : Int = 0
    
    var currentIndex : Int = 0
    
    var currentAsset : PHAsset?
    
    var currentAVasset : AVAsset?
    
    var AssetModel = PhotoViewModel()
    
    var PlayerContainer : PlayerViewController?
    
    var ImageArrayContainer : ImageArrayViewController?
    
    var playViewFrame : CGRect?
    
    var tempView : UIView?
    
    var tempbool : Bool = true
    
    var MenuController  : MenuViewController?
    var naSuperView : UIView?
    var naView : NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        //  conNaView()
        conNaView()
        DispatchQueue.main.async {
            self.updateTransitionOptions()
            self.topBarView.layer.shadowColor = UIColor(displayP3Red: 0.84, green: 0.84, blue: 0.84, alpha: 1).cgColor
            self.topBarView.layer.shadowOffset = CGSize(width: 1, height: 2)
            self.topBarView.layer.shadowRadius = 3
            self.topBarView.layer.shadowOpacity = 1
            self.loadViewData()
        }
    }
    
    func conNaView() {
        naSuperView = UIView(frame: superView.bounds)
        naSuperView?.backgroundColor = UIColor(displayP3Red: 0.13, green: 0.13, blue: 0.13, alpha: 0.7)
        
        naView = NVActivityIndicatorView(frame: CGRect(x: 0  , y: 0, width : 50 ,height : 50) , type: NVActivityIndicatorType.ballGridBeat, color: UIColor.white, padding: 1)
        naView?.center = (naSuperView?.center)!
        naSuperView?.addSubview(naView!)
        
        superView.addSubview(naSuperView!)
        superView.bringSubview(toFront: naSuperView!)
        naSuperView?.isHidden = false
        naView?.startAnimating()
    }
    
    func conAlertView()  {
        let a = SCLAlertView()
        a.showWarning(self.WarningTitle, subTitle: self.Subtitle, closeButtonTitle: "OK", duration: 30, colorStyle: 0xcfecf6, colorTextButton: 0x000000, circleIconImage: nil, animationStyle: SCLAnimationStyle.leftToRight)
        let b = a.view.subviews[0].subviews[0]
        b.backgroundColor = UIColor(displayP3Red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
        b.subviews[1].backgroundColor = UIColor(displayP3Red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
    }
    
    func loadViewData()  {
        
        AssetModel.loadLiveImageAssets(fetchClosure: {(fetch : PHFetchResult?) ->() in
            let tempAsset =  self.AssetModel.imageResult?[self.indexPatchViewModelImage] as! PHAsset?
            if let temp = tempAsset {
                DispatchQueue.main.async {
                    self.getFristLivePhoto(asset: temp)
                }
            } else {
                DispatchQueue.main.sync {
                    self.naView?.stopAnimating()
                }
                DispatchQueue.main.sync {
                   self.conAlertView()
                    self.naSuperView?.isHidden = true
                    print("没livephoto")
                    
                }
                
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
    }
    
   
    
    func updateTransitionOptions() {
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.4
        transition.transformType = .translateMid
        
        transition.frontViewBackgroundColor = UIColor(white: 1, alpha: 1)
        transition.overlayColor = UIColor(white: 0, alpha:0.5)
        
        transition.stiffness = 0.99
        transition.damping = 0.2
        transition.radiusFactor = 0.9
        
        
        // gesture recognizer
        lgr.addTarget(self, action: #selector(LivePViewController.handlePan(_:)))
        
        lgr.edges = .left
        
        touchView.addGestureRecognizer(lgr)
        
    }
    
    func handlePan(_ pan:UIPanGestureRecognizer){
        if pan.state == .began{
            transition.edge = .left
            transition.startInteractiveTransition(self, segueIdentifier: segueMenu, gestureRecognizer: pan)
        }else{
            _ = transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == seguePlayer {
            PlayerContainer = segue.destination as? PlayerViewController
            PlayerContainer?.LPController = self
        }
        if segue.identifier == segueMenu {
            MenuController = segue.destination as? MenuViewController
            
            MenuController?.PhotoViewM = AssetModel
            MenuController?.tempCurrent = currentIndex
            
            MenuController?.delegate = self
            
            MenuController?.transitioningDelegate = self.transition
            MenuController?.modalPresentationStyle = .custom
        }
        if segue.identifier == segueImage {
            ImageArrayContainer = segue.destination as? ImageArrayViewController
             self.ImageArrayContainer?.returnAVAsset = self.currentAVasset
             self.ImageArrayContainer?.videoToQImage()
            ImageArrayContainer?.transitioningDelegate = self.transition
           ImageArrayContainer?.modalPresentationStyle = .custom
            
        }
    }
    
    func getFristLivePhoto(asset : PHAsset)
    {
        
        
        let resources = PHAssetResource.assetResources(for: asset)
        
        for resource in resources {
            
            if resource.type == .pairedVideo {
                let moviePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(resource.originalFilename)
                let movieURL = URL(fileURLWithPath: moviePath)
                let manager = FileManager()
                if manager.fileExists(atPath: moviePath) {
                    do { try manager.removeItem(atPath: moviePath) }
                    catch {
                    }
                }
                let movieData = NSMutableData()
                
                // options.
                let opts = PHAssetResourceRequestOptions()
                
                opts.isNetworkAccessAllowed = true
                var tempPro : Double?
                opts.progressHandler = { pro in
                    print(pro)
                    tempPro = pro
                    DispatchQueue.main.sync {
                        self.tempbool = false
                        //    self.progressView.progress = Float(pro)
                    }
                }
                
                func loadMovieData() {
                    PHAssetResourceManager.default().requestData(for: resource, options: opts, dataReceivedHandler: { (data) -> Void in
                        movieData.append(data)
                    }) { (err) -> Void in
                        
                        if let error = err {
                            if tempPro == 0.500 {
                                //  loadMovieData()
                                self.getFristLivePhoto(asset: asset)
                            }
                            if tempPro == 1.0 {
                                self.tempbool = false
                            }
                            //                            _ = SCLAlertView().showWarning(self.WarningTitle, subTitle: self.Subtitle)
                            if  tempPro == nil || tempPro! < Double(0.40) {
                            DispatchQueue.main.async {
                                self.conAlertView()
                                self.naView?.stopAnimating()
                                self.naSuperView?.isHidden = true
                            }
                            print("错误",error)
                            }
                        }
                        else {
                            if self.tempbool == false {
                                do {
                                    try movieData.write(to: movieURL, options: NSData.WritingOptions.atomicWrite)
                                    let movieAsset = AVAsset(url: movieURL)
                                    self.currentAVasset = movieAsset
                                    if let temp = self.currentAVasset {
                                        self.PlayerContainer?.playerAVasset = temp
                                        //                                        self.PlayerContainer?.finalVideoURL = movieURL as NSURL?
//                                        self.ImageArrayContainer?.returnAVAsset = temp
                                    //    self.ImageArrayContainer?.returnAVAsset = temp
                                        DispatchQueue.main.sync {
                                            //self.ImageArrayContainer?.videoToQImage()
//                                            self.ImageArrayContainer?.videoToQImage()
                                            
                                            self.PlayerContainer?.configurePlay()
                                            self.PlayerContainer?.configurePlay()
                                            self.tempbool = true
                                            self.naView?.stopAnimating()
                                            self.naSuperView?.isHidden = true
                                        }
                                    }
                                } catch {
                                    print("currentAVasset读取不成功")
                                    //                                    _ = SCLAlertView().showWarning(self.WarningTitle, subTitle: self.Subtitle)
                                } }
                        }
                    }
                }
                // load movie data
                loadMovieData()
            }
        }
    }
    
    @IBAction func MenuAction(_ sender: UIButton) {
        transition.edge = .left
        transition.startingPoint = (sender as AnyObject).center
        
        performSegue(withIdentifier: segueMenu, sender: self)
    }
    
    @IBAction func ImageAction(_ sender: Any) {
        transition.edge = .right
        transition.startingPoint = (sender as AnyObject).center
        
        performSegue(withIdentifier: segueImage, sender: self)
    }
    
    
    func sendIndex(index : Int , sender : AnyObject) {
        self.indexPatchViewModelImage = index
        if (self.PlayerContainer?.canCloseN)! {
            self.PlayerContainer?.closeNotification()
        }
    //    ImageArrayContainer?.displayKeyframeImages = []
        conNaView()
        DispatchQueue.main.async {
            self.loadViewData()
        }
        
    }
    
    func saveCurrentIndex(index: Int) {
        self.currentIndex = index
    }
    
}

