//
//  AVAsset+.swift
//  VideoReverser
//
//  Created by AuraOtsuka on 2016/03/26.
//  Copyright © 2016年 AuraOtsuka. All rights reserved.
//

import AVFoundation

extension AVAsset {
    func reversedAsset(_ outputURL: URL, callback: @escaping (AVAsset) -> Void) -> AVAsset? {
        do {
            
            let reader = try AVAssetReader(asset: self)
            
            guard let videoTrack = tracks(withMediaType: AVMediaTypeVideo).last else {
                return .none
            }
            
            let readerOutputSettings: [String:AnyObject] = [
                "\(kCVPixelBufferPixelFormatTypeKey)": Int(kCVPixelFormatType_420YpCbCr8PlanarFullRange) as AnyObject
            ]
            let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
            
            reader.add(readerOutput)
            reader.startReading()
            
            // Read in frames (CMSampleBuffer is a frame)
            var samples = [CMSampleBuffer]()
            while let sample = readerOutput.copyNextSampleBuffer() {
                samples.append(sample)
            }
            
            // Write to AVAsset
            let manager = FileManager()
            if manager.fileExists(atPath: outputURL.path) {
                try manager.removeItem(atPath: outputURL.path)
            }
            
            let writer = try AVAssetWriter(outputURL: outputURL, fileType: AVFileTypeMPEG4)
            
            let writerOutputSettings: [String:AnyObject] = [
                AVVideoCodecKey: AVVideoCodecH264 as AnyObject,
                AVVideoWidthKey: videoTrack.naturalSize.width as AnyObject,
                AVVideoHeightKey: videoTrack.naturalSize.height as AnyObject,
                AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: videoTrack.estimatedDataRate] as AnyObject
            ]
            
            let sourceFormatHint = videoTrack.formatDescriptions.last as! CMFormatDescription
            let writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: writerOutputSettings, sourceFormatHint: sourceFormatHint)
            writerInput.expectsMediaDataInRealTime = false
            writerInput.transform = videoTrack.preferredTransform
            
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: .none)
            writer.add(writerInput)
            writer.startWriting()
            writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(samples[0]))
            
            for (index, sample) in samples.enumerated() {
                let presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
                
                if let imageBufferRef = CMSampleBufferGetImageBuffer(samples[samples.count - index - 1]) {
                    pixelBufferAdaptor.append(imageBufferRef, withPresentationTime: presentationTime)
                }
                
                while !writerInput.isReadyForMoreMediaData {
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
            
            writer.finishWriting {
                callback(AVAsset(url: outputURL))
                
            }
            return AVAsset(url: outputURL)
        }
        catch let error as NSError {
            print("\(error)")
            return .none
        }
    }
}
