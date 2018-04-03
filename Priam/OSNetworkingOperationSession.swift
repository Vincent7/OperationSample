//
//  OSNetworkingOperationSession.swift
//  OperationSample
//
//  Created by Vincent on 02/02/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
//protocol OperationDelegate {
//    func didOperationFinish
//
//}
class OSNetworkingOperationSession: NSObject {
    
    static let sharedInstance:OSNetworkingOperationSession = {
        let instance = OSNetworkingOperationSession()
        return instance
    }()
    lazy var waitingLoadOperations = [String:Array<OSImageHTTPSessionOperation>]()
    let lock:NSLock = NSLock.init()
    lazy var downloadsInProgress = [NSIndexPath:Operation]()
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return queue
    }()
    let dQueue = VJBaseOperationQueue()
    
    
    lazy var mainOperationsInProgress = [NSIndexPath:Operation]()
    lazy var mainOperationsQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return queue
    }()
    func addOperationToWaitingImageLoadQueue(operation:OSImageHTTPSessionOperation,imageIdentifier:String) -> Void {
        lock.lock()
        var operations:Array<OSImageHTTPSessionOperation> = self.waitingLoadOperations[imageIdentifier] ?? Array<OSImageHTTPSessionOperation>()
        operations.append(operation)
        self.waitingLoadOperations[imageIdentifier] = operations
        lock.unlock()
    }
    func updateWaitingLoadOperations(imageIdentifier:String, operationStatus:CacheStatus) -> UIImage {
//        NSLock.lock()
        
        lock.lock()
        var cacheImage:UIImage!
        if operationStatus == .alreadyCached {
            let operations:Array<OSImageHTTPSessionOperation> = self.waitingLoadOperations[imageIdentifier] ?? Array<OSImageHTTPSessionOperation>()
            cacheImage = OSNetworkImage.getCache(identifier: imageIdentifier) as! UIImage
            for operation in operations {
                operation.completeOperation(cacheIdentifier: imageIdentifier, image: cacheImage)
            }
            self.waitingLoadOperations.removeValue(forKey: imageIdentifier)
        }
        lock.unlock()
        return cacheImage
        
        
//        NSLock.unlock()
    }
}
