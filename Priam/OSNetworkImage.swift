//
//  OSNetworkImage.swift
//  OperationSample
//
//  Created by Vincent on 16/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class OSNetworkImage: NSObject,Cachable {
    
    //TODO: 多线程安全问题
    var image:UIImage?
    

    static func getCache(identifier: String) -> Any? {
        guard let cacheImage = OSCacheFactory.sharedInstance.imageCache.object(forKey: identifier as NSString) else {
            return nil
        }
        return cacheImage
    }
    
    static func saveCache(identifier: String, object: Any) -> Bool {
        OSCacheFactory.sharedInstance.imageCache.setObject(object as! UIImage, forKey: identifier as NSString)
        
        return true
    }
    static func cacheStatus(identifier: String) -> CacheStatus {
        
        guard let status:CacheStatus = OSCacheFactory.sharedInstance.imageStatusIndex[identifier] else {
            OSCacheFactory.sharedInstance.imageStatusIndex[identifier] = .haveNoCached
            return .haveNoCached
        }
        return status
    }
    static func updateCacheStatus(identifier: String, status: CacheStatus) {
        let oldStatus:CacheStatus = OSCacheFactory.sharedInstance.imageStatusIndex[identifier]!
        if status == .alreadyCached && oldStatus != .alreadyCached {
            //TODO: 通知对应Identifier operation更新image
        }
        OSCacheFactory.sharedInstance.imageStatusIndex[identifier] = status
    }
}
