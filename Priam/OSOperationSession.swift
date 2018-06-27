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
class OSOperationSession: NSObject {
    
    static let sharedInstance:OSOperationSession = {
        let instance = OSOperationSession()
        return instance
    }()
    lazy var waitingLoadOperations = [String:Array<OSImageHTTPSessionOperation>]()
    let lock:NSLock = NSLock.init()
    lazy var downloadsInProgress = [NSIndexPath:Operation]()
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "DownloadQueue"
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return queue
    }()
    let dQueue = VJBaseOperationQueue()
    
    
    lazy var mainOperationsInProgress = [NSIndexPath:Operation]()
    lazy var mainOperationsQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "ImageFiltrationQueue"
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return queue
    }()
    //如果Operation中的请求内容被标记为正在被请求，则不发生新的请求，而是让该Operation待命到该内容请求完毕
    func addOperationToWaitingImageLoadQueue(operation:OSImageHTTPSessionOperation,imageIdentifier:String) -> Void {
        lock.lock()
        var operations:Array<OSImageHTTPSessionOperation> = self.waitingLoadOperations[imageIdentifier] ?? Array<OSImageHTTPSessionOperation>()
        operations.append(operation)
        self.waitingLoadOperations[imageIdentifier] = operations
        lock.unlock()
    }
    //当一个内容请求完毕时，检查是否有多个Operation依赖该内容，并分发内容至这些Operation
    func updateWaitingLoadOperations(imageIdentifier:String, operationStatus:CacheStatus) -> UIImage {
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
    }
}
