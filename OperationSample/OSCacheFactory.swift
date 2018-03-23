//
//  OSCacheFactory.swift
//  OperationSample
//
//  Created by Vincent on 13/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
enum CacheIOError: Error {
    case foundNoCache
    case unknownError
}
enum CacheStatus: String {
    case downloading = "DOWNLOADING"
    case alreadyCached = "ALREADY_CACHED"
    case haveNoCached = "HAVE_NO_CACHED"
    fileprivate var keyPath: String { return self.rawValue }
}
protocol Cachable {
    static func updateCacheStatus(identifier:String, status:CacheStatus) -> Void
    static func cacheStatus(identifier:String) -> CacheStatus
    static func getCache(identifier:String) -> Any?
    static func saveCache(identifier:String, object:Any) -> Bool
}
class OSCacheFactory: NSObject {
    
    // MARK: Shared Instance
    static let sharedInstance:OSCacheFactory = {
        let instance = OSCacheFactory()
        return instance
    }()
    var imageCache = NSCache<NSString, UIImage>()
    var imageStatusIndex = [String: CacheStatus](){
        didSet{
            print("values change")
        }
    }
    var imageLoadOperationsStatusIndex = NSCache<NSString, UIImage>()
    var networkRequestOperation:OSHTTPSessionOperation?
//    func getCache(identifier:String!) throws -> Any {
//        guard let cacheImage = self.imageCache.object(forKey: identifier! as NSString) else {
//            throw CacheIOError.foundNoCache
//        }
//        return cacheImage
//    }
//    func cacheImage(imageIdentifier identifier:String!, image:UIImage!){
//        imageCache.setObject(image, forKey: identifier as NSString)
//
//    }
}
