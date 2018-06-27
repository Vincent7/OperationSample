//
//  OSHTTPSessionOperation.swift
//  OperationSample
//
//  Created by Vincent on 02/02/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
import AFNetworking

class OSHTTPSessionOperation: OSBaseAsynchronousOperation {
    var manager:AFHTTPSessionManager?
    var task:URLSessionTask?
    
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        fileprivate var keyPath: String { return self.rawValue }
    }
    
    enum Result {
        case Success(String)
        case Error(NSError)
    }
    
    override init() {
        super.init()
        self.task = URLSessionTask()
    }
    
    class func httpOperation(manager:AFHTTPSessionManager,
                             httpMethod:HTTPMethod,
                             urlString:String,
                             parameters:Dictionary<String, String>?,
                             uploadProgress:@escaping (_ uploadProgress:Progress) -> Void,
                             downloadProgress:@escaping (_ downloadProgress:Progress) -> Void,
                             completionHandler:@escaping (_ task:URLSessionDataTask?,_ responseObject:Any?, _ result:Result) -> Void)
        -> OSHTTPSessionOperation{
        let operation = OSHTTPSessionOperation()
        let task = manager.dataTask(withHTTPMethod: httpMethod.rawValue,
                                    urlString: urlString,
                                    parameters: parameters,
                                    uploadProgress: uploadProgress as? (Progress?) -> Void,
                                    downloadProgress: downloadProgress as? (Progress?) -> Void,
                                    success: { (task,responseObject) in
                                        completionHandler(task,responseObject,.Success("Done"))
                                        operation.completeOperation()
        },
                                    failure: { (task,error:Error!) in
                                        completionHandler(task,nil,.Error(error! as NSError))
                                        operation.completeOperation()
        })
        operation.task = task
        
        return operation
        
    }
    
    override func main() {
        self.task?.resume()
    }
    override func completeOperation() {
        print(self.task?.description," is finished")
        self.task = nil
        
        super.completeOperation()
    }
    override func cancel() {
        self.task?.cancel()
        super.cancel()
    }
}
