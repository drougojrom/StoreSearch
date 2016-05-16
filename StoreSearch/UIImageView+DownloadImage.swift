//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Roman Ustiantcev on 16/05/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImageWithURL(url: NSURL) -> NSURLSessionDownloadTask {
        
        let session = NSURLSession.sharedSession()
        
        // 1 - create download task
        let downloadTask = session.downloadTaskWithURL(url, completionHandler: { [weak self] url, response, error in
            
            // 2 - check if error is nil and if we have suc. with data
            if error == nil, let url = url,
            // 3 - load file into NSData object
                data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                // 4 - put into image
                dispatch_async(dispatch_get_main_queue(), {
                    if let strongSelf = self {
                        strongSelf.image = image
                    }
                })
            }
        })
    downloadTask.resume()
    return downloadTask
    }
}
