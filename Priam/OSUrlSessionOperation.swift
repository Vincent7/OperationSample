//
//  OSNetworkRequestOperation.swift
//  OperationSample
//
//  Created by Vincent on 29/01/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
import AFNetworking

class OSUrlSessionOperation: OSBaseAsynchronousOperation {
    var task: URLSessionTask?
    override init() {
        super.init()
        self.task = URLSessionTask()
    }

    
    class func dataOperationWith(manager:AFURLSessionManager,
                                 request:URLRequest,
                       completionHandler:@escaping (_ response:URLResponse, _ responseObject:Any?, _ error:Error?) -> Void
                                               ) -> OSUrlSessionOperation {
        let operation = OSUrlSessionOperation()
        operation.task = manager.dataTask(with: request, uploadProgress: nil, downloadProgress: nil, completionHandler: { (response, responseObject, error) in
            completionHandler(response,responseObject,error)
            operation.completeOperation()
        })
        
        return operation
    }
    
    class func dataOperationWith(manager:AFURLSessionManager,
                                 request:URLRequest,
                                 uploadProgress:@escaping (_ uploadProgress:Progress) -> Void,
                                 downloadProgress:@escaping (_ downloadProgress:Progress) -> Void,
                       completionHandler:@escaping (_ response:URLResponse, _ responseObject:Any?, _ error:Error?) -> Void
        ) -> OSUrlSessionOperation {
        let operation = OSUrlSessionOperation()
        operation.task = manager.dataTask(with: request, uploadProgress: uploadProgress, downloadProgress: downloadProgress, completionHandler: { (response, responseObject, error) in
            completionHandler(response,responseObject,error)
            operation.completeOperation()
        })
        
        return operation
    }
    override func completeOperation() -> Void {
        self.task = nil
        super.completeOperation()
    }
}
