//
//  PhotoViewModel.swift
//  LiveP2
//
//  Created by PD on 2017/1/23.
//  Copyright © 2017年 PD. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotoViewModel {
    
    var requestOption : PHFetchOptions {
        let opts = PHFetchOptions()
        opts.predicate = NSPredicate(format: "mediaSubtype & %d != 0", PHAssetMediaSubtype.photoLive.rawValue)
        opts.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return opts
    }
    
    func requestAccessToPhotos(authClosure: @escaping (PHAuthorizationStatus) ->())  {
        PHPhotoLibrary.requestAuthorization{(authStatus: PHAuthorizationStatus)
            -> Void in
            authClosure(authStatus)}
    }
    
    var imageResult : PHFetchResult<AnyObject>?
    
    func loadLiveImageAssets(fetchClosure: @escaping (PHFetchResult<AnyObject>?) ->())  {
        requestAccessToPhotos{(auth: PHAuthorizationStatus) in
            if auth == PHAuthorizationStatus.authorized {
                let fetchResult : PHFetchResult? = PHAsset.fetchAssets(with: .image, options: self.requestOption)
                if (fetchResult?.count)! > 0 {
                self.imageResult = fetchResult as? PHFetchResult<AnyObject>
                      fetchClosure(fetchResult as? PHFetchResult<AnyObject>)
                } else {
                    print("没livephoto")
                     fetchClosure(nil)
                }
            }
            else {
                print("未授权")
                fetchClosure(nil)
            }
        }
    }
    
    var photoSelectedCallBack : ((PHAsset) ->())?
    
    var numItemS : Int {        
        let count = imageResult.map({
            (fetch: PHFetchResult) -> Int in
            fetch.count})
        return count ?? 0
    }
    
    var selectedAsset : PHAsset? {
        didSet {
            if let hasAsset = selectedAsset , let callback = photoSelectedCallBack {
                callback(hasAsset)
            }
        }
    }
    
    func assetForIndexPath(indexPath : NSIndexPath)-> PHAsset? {
        return imageResult.map({
            (fetch : PHFetchResult) -> PHAsset in (fetch.object(at: indexPath.row)) as! PHAsset
        })
    }

}
