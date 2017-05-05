//
//  MenuViewController.swift
//  LiveP2
//
//  Created by PD on 2017/1/23.
//  Copyright © 2017年 PD. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import ElasticTransition

protocol MenuViewDelegate  {
    func sendIndex(index : Int , sender : AnyObject)
    func saveCurrentIndex(index : Int)
}

class MenuViewController: UIViewController, iCarouselDelegate, iCarouselDataSource , ElasticMenuTransitionDelegate {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet var iCarouselView: iCarousel!
    
    var contentLength:CGFloat = 210
    var dismissByBackgroundTouch = true
    var dismissByBackgroundDrag = true
    var dismissByForegroundDrag = true
    
    var PhotoViewM = PhotoViewModel()
    
    var tempIndex : Int?
    
    var delegate : MenuViewDelegate?
    
    var tempCurrent : Int = 0
    var widthView : CGFloat!
    var heightView : CGFloat!
    
    var livePhotoView : PHLivePhotoView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        iCarouselView.type = .coverFlow
        iCarouselView.isVertical = true
        contentLength = iCarouselView.frame.width * 0.75
        self.returnCurrentIndex()

        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        if delegate != nil {
            delegate?.saveCurrentIndex(index: iCarouselView.currentItemIndex)
        }
    }
    
    func returnCurrentIndex() {
        iCarouselView.currentItemIndex = tempCurrent
        iCarouselView.currentItemIndex =  iCarouselView.currentItemIndex + 1
        iCarouselView.currentItemIndex =  iCarouselView.currentItemIndex - 1

    }
    
    
    func numberOfItems(in carousel: iCarousel) -> Int {
       return self.PhotoViewM.numItemS
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
//        var label: UILabel
        //  var itemView: PHLivePhotoView
      
        
        var itemView : UIImageView
        
      
        
        var asset : PHAsset!
        
        let nsindexPath = NSIndexPath(item: index, section: 1)
        
        let size = CGSize(width: 250, height: 250)
        
        asset = PhotoViewM.assetForIndexPath(indexPath: nsindexPath)
        
        itemView = UIImageView(frame: CGRect(x: 0, y: -20, width: 250, height: 250))
        
     //   baseView = UIView(frame: itemView.frame)
        
        itemView.image = UIImage(named: "page.png")
        
        var AssetImage : UIImage!
        let opt = PHImageRequestOptions()
        opt.isSynchronous = true
        opt.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: opt, resultHandler: {
            image , _ in
            if let hasimage = image {
                AssetImage = hasimage
                DispatchQueue.main.async {
                    itemView.image = AssetImage
                    //  self.icarouselView.reloadData()
                    let imgRef = AssetImage.cgImage
                    let w = imgRef?.width
                    let h = imgRef?.height

                    if w!>=h! {
                        let scaleH = h!*250/w!
                         itemView.frame = CGRect(x: 0, y: -20, width: 250, height: scaleH)
                      
                    } else {
                        let scaleW = w!*250/h!
                        let scaleX = (250 - scaleW) / 2
                        itemView.frame = CGRect(x: scaleX , y: -20, width: scaleW, height: 250)
                    }
                    
                }
            }
        })
    
  
        
        
        itemView.contentMode = .scaleAspectFit
        
//        label = UILabel(frame: itemView.bounds)
//        label.backgroundColor = .clear
//        label.textAlignment = .center
//        label.font = label.font.withSize(50)
//        label.tag = 1
//        itemView.addSubview(label)
//
//        label.text = "\(index)"
      //  itemView.frame =
//       itemView.layer.borderWidth = 5
//        itemView.layer.borderColor = UIColor.black.cgColor
        itemView.layer.shadowColor = UIColor(colorLiteralRed: 0.08, green: 0.08, blue: 0.06, alpha: 1).cgColor
        itemView.layer.shadowOffset = CGSize(width: 1, height: 5)
        itemView.layer.shadowRadius = 3
        itemView.layer.shadowOpacity = 1
        
   //     baseView.addSubview(itemView)
        return itemView

    }

    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
      let currentFrameW = iCarouselView.currentItemView?.frame.width
        let currentFrameH = iCarouselView.currentItemView?.frame.height
        
        if tempIndex != nil {
            iCarouselView.itemView(at: tempIndex!)?.viewWithTag(2)?.removeFromSuperview()
        }

        if iCarouselView.currentItemIndex >= 0  {
            var nsindexPath = NSIndexPath(item: iCarouselView.currentItemIndex , section: 1)
            let size = CGSize(width: 250, height: 250)
            var asset : PHAsset!
            asset = PhotoViewM.assetForIndexPath(indexPath: nsindexPath)
            

            livePhotoView = PHLivePhotoView(frame: (self.iCarouselView.currentItemView?.frame)!)

            livePhotoView?.tag = 2
            livePhotoView?.isMuted = true
            livePhotoView?.startPlayback(with: .full)
            livePhotoView?.contentMode = .scaleAspectFit
//            livePhotoView.layer.borderWidth = 7
//            livePhotoView.layer.borderColor = UIColor.black.cgColor
            var AssetLivePhoto = PHLivePhoto()
            
            var livePhotoOption : PHLivePhotoRequestOptions {
                let requestOption = PHLivePhotoRequestOptions()
                requestOption.isNetworkAccessAllowed = true
                requestOption.deliveryMode = .opportunistic
                return requestOption
            }
            
            func getL() {
                nsindexPath = NSIndexPath(item: iCarouselView.currentItemIndex , section: 1)
                asset = PhotoViewM.assetForIndexPath(indexPath: nsindexPath)
                PHImageManager.default().requestLivePhoto(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFit, options: livePhotoOption, resultHandler: {
                    liveP, _ in
                    let currentTemp = self.iCarouselView.currentItemIndex
                    if let hasImage = liveP {
                        AssetLivePhoto = hasImage
                        self.livePhotoView?.livePhoto = AssetLivePhoto
                        DispatchQueue.main.async {
                            if nsindexPath.item == self.iCarouselView.currentItemIndex {
                                if currentTemp == self.iCarouselView.currentItemIndex {
                                self.iCarouselView.currentItemView?.addSubview(self.livePhotoView!)
                                }
                            } else {
                                getL()                        }
                        }
                    }
                })
            }
            
            PHImageManager.default().requestLivePhoto(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFit, options: livePhotoOption, resultHandler: {
                liveP, _ in
                let currentTemp = self.iCarouselView.currentItemIndex
                if let hasImage = liveP {
                    AssetLivePhoto = hasImage
                    self.livePhotoView?.livePhoto = AssetLivePhoto
                 
                    DispatchQueue.main.async {
                        if nsindexPath.item == self.iCarouselView.currentItemIndex {
                            let imgRef = AssetLivePhoto.size
                            let w = imgRef.width
                            let h = imgRef.height
                            
                            if h >= w {
                                let scaleW = w*250/h
                   //             let scaleX = (250 - scaleW) / 2
                                self.livePhotoView?.frame = CGRect(x: 0 , y: 0, width: scaleW, height: 250)
                            } else {
                                self.livePhotoView?.frame = (self.iCarouselView.currentItemView?.bounds)!
                            }
                            if currentTemp == self.iCarouselView.currentItemIndex {
                            self.iCarouselView.currentItemView?.addSubview(self.livePhotoView!)
                            }
                        }
                    }
                }  else {
                            getL()                        }
                        
                        let imgRef = AssetLivePhoto.size
                        let w = imgRef.width
                        let h = imgRef.height
                        
                        if h >= w {
                            let scaleW = w*250/h
                      //      let scaleX = (250 - scaleW) / 2
                            self.livePhotoView?.frame = CGRect(x: 0 , y: 0, width: scaleW, height: 250)
                        }
                
            })
        }
        
        tempIndex = iCarouselView.currentItemIndex
        
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {

            dismiss(animated: true, completion: {
                if self.delegate != nil {
                    self.delegate?.sendIndex(index: index, sender: self.iCarouselView)
                }
            })
    }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case iCarouselOption.wrap:
            return 1
//        case iCarouselOption.showBackfaces:
//            return 0.0
        case iCarouselOption.spacing:
            return value * 1.7
//        case iCarouselOption.fadeMinAlpha:
//            return value
        case iCarouselOption.count:
            return 5
//        case iCarouselOption.angle:
//            return value * 1.0
        case iCarouselOption.arc:
            return value * 0.6
        case iCarouselOption.radius:
            return value * 1.5
//        case iCarouselOption.offsetMultiplier:
//            return value
        case iCarouselOption.tilt:
            return 0.9
        default:
            return value
        }
    }
    
}
