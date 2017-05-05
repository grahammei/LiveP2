//
//  ImageArrayViewController.swift
//  LiveP2
//
//  Created by PD on 2017/1/23.
//  Copyright © 2017年 PD. All rights reserved.
//

import UIKit
import Photos
import ElasticTransition
class ImageArrayViewController: UIViewController, iCarouselDelegate, iCarouselDataSource, ElasticMenuTransitionDelegate {
    
//    var dismissByBackgroundDrag = true
//    var dismissByForegroundDrag = true
    
    var returnAVAsset : AVAsset!
    var returnNSURL : NSURL!
    
    var widthView : CGFloat!
    var heightView : CGFloat!
    
    var displayKeyframeImages: [KeyframeImage] = []
    
    let screenBounds : CGRect = UIScreen.main.bounds
    
 
    @IBOutlet weak var IcaouselView: iCarousel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
  
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // Do any additional setup after loading the view.
        IcaouselView.type = .coverFlow
        IcaouselView.isVertical = false
        widthView = IcaouselView.bounds.width
        heightView = IcaouselView.bounds.height
        IcaouselView.reloadData()
        print(screenBounds)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func BackAction(_ sender: Any) {

        IcaouselView.removeFromSuperview()
        
        self.dismiss(animated: true, completion: nil )
       
    }
    
    func configureImageArray() {
      
        IcaouselView.reloadData()
        let imgRef = self.displayKeyframeImages[0].image.cgImage
        let w = imgRef?.width
        let h = imgRef?.height
        
        //                    var itemW : CGFloat
        //                    var itemH : CGFloat
        if w!>h! {
            //   let scale = icarouseW / CGFloat(w!)
            self.IcaouselView.type = .coverFlow2
        } else {
            self.IcaouselView.type = .coverFlow
    
        }
    }
    
    func videoToQImage() {
        displayKeyframeImages = []
        let imageGenerator = KeyframeImageGenerator()
        
        imageGenerator.generateDefaultSequenceOfImages(from: returnAVAsset) { [weak self] in
            self?.displayKeyframeImages.append(contentsOf: $0)
            DispatchQueue.main.async {
                               self?.configureImageArray()
            }
        }
        
    }
    
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return  self.displayKeyframeImages.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
//        var label: UILabel
        //  var itemView: PHLivePhotoView
        var itemView : UIImageView
        
        itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: widthView, height: heightView))
        
        itemView.image = UIImage(named: "page.png")
        itemView.image = displayKeyframeImages[index].image
        
      
        let imgRef = itemView.image?.cgImage
        let w = imgRef?.width
        let h = imgRef?.height
        var screenX : CGFloat = 0
        if screenBounds.width > 400 {
            screenX = 0.3
        }
        //                    var itemW : CGFloat
        //                    var itemH : CGFloat
        if w!>h! {
            //   let scale = icarouseW / CGFloat(w!)
            let tempW = Int(widthView / (1.3 - screenX))
            let scaleH = h! * tempW / w!
            itemView.frame = CGRect(x: 0, y: 0, width: tempW, height: scaleH)
          //  IcaouselView.type = .invertedTimeMachine
        } else {
            let tempH = Int(widthView / (1.2 - screenX))
            let scaleW = w! * tempH / h!
            itemView.frame = CGRect(x: 0 , y: 0, width: scaleW, height: tempH)
          //  IcaouselView.type = .coverFlow
        }

        

        itemView.layer.shadowColor = UIColor(colorLiteralRed: 0.13, green: 0.13, blue: 0.13, alpha: 1).cgColor
        itemView.layer.shadowOffset = CGSize(width: 6, height: 4)
        itemView.layer.shadowRadius = 3
        itemView.layer.shadowOpacity = 1
        
        return itemView
        
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
//        if let myWebsite = URL(string: "http://www.mstcode.com")
//        {
//            let messageStr:String  = "Learn how to build iPhone apps"
            let img: UIImage = displayKeyframeImages[index].image
//            do {
//                let fileData = try Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "IMG1", ofType: "gif")!))
//                print(URL(fileURLWithPath: Bundle.main.path(forResource: "IMG1", ofType: "gif")!))
//                //           let ns : NSObject?
//                let nsd : NSData!
//                nsd = fileData as NSData?
//                let tempAvasset = returnNSURL
                let shareItems:Array = [ img ] as [Any]
                let activityController = UIActivityViewController(activityItems:shareItems, applicationActivities: nil)
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    activityController.popoverPresentationController?.sourceView = self.view
                }
                
                
                self.present(activityController, animated: true,completion: nil)
            }
//            catch {
//                print("kkkkkkkkkkkkkkkkkkkkk")
//            }
//        }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
//        case iCarouselOption.wrap:
//            return value
//        case iCarouselOption.showBackfaces:
//            return value
        case iCarouselOption.spacing:
            var screenX : CGFloat = 0
            if screenBounds.width < 400 || IcaouselView.type == .coverFlow {
                screenX = 1.3
            }
            return value * (0.7 + screenX)
//        case iCarouselOption.fadeMinAlpha:
//            return value
//        case iCarouselOption.count:
//            return 10
//        case iCarouselOption.angle:
//            return value
//        case iCarouselOption.arc:
//            return value
//        case iCarouselOption.radius:
//            return value
//        case iCarouselOption.offsetMultiplier:
//            return value
        case iCarouselOption.tilt:
//
//            return value * (0.8 + screenX)
            return value * 0.9
        default:
            return value
        }
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
    

