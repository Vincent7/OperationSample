//
//  OSImageHTTPSessionOperation.swift
//  OperationSample
//
//  Created by Vincent on 16/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
import AFNetworking

class OSImageHTTPSessionOperation: OSHTTPSessionOperation {
    weak var operationSession:OSOperationSession?
    
    var networkImage:UIImage?
    var imageLoadStatus:CacheStatus = .haveNoCached

    class func httpOperation(manager:AFHTTPSessionManager,
                             operationSession:OSOperationSession,
                             httpMethod:HTTPMethod,
                             urlString:String,
                             parameters:Dictionary<String, String>?,
                             uploadProgress:@escaping (_ uploadProgress:Progress) -> Void,
                             downloadProgress:@escaping (_ downloadProgress:Progress) -> Void,
                             completionHandler:@escaping (_ task:URLSessionDataTask?,_ responseObject:Any?, _ result:Result) -> Void)
        -> OSHTTPSessionOperation{
            let operation = OSImageHTTPSessionOperation()
            operation.operationSession = operationSession
            let imageStatus:CacheStatus = OSNetworkImage.cacheStatus(identifier: urlString)
            switch imageStatus {
            case .alreadyCached:
                let networkImage = OSNetworkImage.getCache(identifier: urlString) as! UIImage
                //                operation.networkImage.image = networkImage
                OSNetworkImage.updateCacheStatus(identifier: urlString, status: .alreadyCached)
                completionHandler(nil,networkImage,.Success("Have Cache"))
                operation.networkImage = networkImage
                operation.imageLoadStatus = .alreadyCached
                operation.completeOperation(cacheIdentifier: urlString)
            case .downloading:
                operation.imageLoadStatus = .downloading
                operation.operationSession?.addOperationToWaitingImageLoadQueue(operation: operation, imageIdentifier: urlString)
//                operation.completeOperation()
            case .haveNoCached:
                OSNetworkImage.updateCacheStatus(identifier: urlString, status: .downloading)
                let task = manager.dataTask(withHTTPMethod: httpMethod.rawValue,
                                            urlString: urlString,
                                            parameters: parameters,
                                            uploadProgress: uploadProgress as? (Progress?) -> Void,
                                            downloadProgress: downloadProgress as? (Progress?) -> Void,
                                            success: { (task,responseObject) in
                                                let image = UIImage(data: responseObject as! Data)
                                                
                                                
                                                _ = OSNetworkImage.saveCache(identifier: urlString, object: image!)
                                                completionHandler(task,image,.Success("Download Done"))
                                                operation.networkImage = image
                                                operation.imageLoadStatus = .alreadyCached
                                                operation.completeOperation(cacheIdentifier: urlString)
                },
                                            failure: { (task,error:Error!) in
                                                completionHandler(task,nil,.Error(error! as NSError))
                                                operation.imageLoadStatus = .alreadyCached
                                                operation.completeOperation()
                })
                operation.task = task
            default:
                operation.cancel()
                break
            }
            
            
            
            
            return operation
            
    }
    override func main() {
        switch imageLoadStatus {
        case .haveNoCached:
            super.main()
        default:
            return
        }
        
    }
    func completeOperation(cacheIdentifier:String,image:UIImage) {
        self.networkImage = image
        OSNetworkImage.updateCacheStatus(identifier: cacheIdentifier, status: .alreadyCached)
        self.completeOperation()
    }
    func completeOperation(cacheIdentifier:String) {
        if self.imageLoadStatus == .alreadyCached {
            self.networkImage = self.operationSession?.updateWaitingLoadOperations(imageIdentifier: cacheIdentifier, operationStatus: self.imageLoadStatus)
        }
        
        OSNetworkImage.updateCacheStatus(identifier: cacheIdentifier, status: .alreadyCached)
        self.completeOperation()
    }
}
