//
//  DownloadScriptPreviewOperation.swift
//  OperationSample
//
//  Created by Vincent on 29/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
import AFNetworking

class DownloadScriptPreviewOperation: VJBaseGroupOperation {
    let scriptItem: ScriptObject
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        fileprivate var keyPath: String { return self.rawValue }
    }
    
    lazy var sessionManager:AFHTTPSessionManager = {
        let urlCache = URLCache.init(memoryCapacity: 4*1024*1024,
                                     diskCapacity: 20*1024*1024,
                                     diskPath: nil)
        URLCache.shared = urlCache
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 15
        
        let sessionManager = AFHTTPSessionManager.init(sessionConfiguration: configuration)
        let responseSerializer = AFHTTPResponseSerializer.init()
        responseSerializer.acceptableContentTypes = Set(["application/json", "text/json", "text/javascript","text/html","image/webp","image/jpeg"])
        //        sessionManager.requestSerializer = AFJSONRequestSerializer.seri
        sessionManager.responseSerializer = responseSerializer
        sessionManager.requestSerializer = AFHTTPRequestSerializer.init()
        return sessionManager
    }()
    
    init(context:inout ScriptObject) {
        self.scriptItem = context
        super.init(operations: [])
        
        //Sample image url
        let url = context.previewImageUrl
        let task = sessionManager.dataTask(withHTTPMethod: HTTPMethod.get.rawValue,
                                           urlString: url!.absoluteString,
                                    parameters: nil,
                                    uploadProgress: { (progres) in
                                        //            print(progres)
        },
                                    downloadProgress: { (progres) in
                                        //            print(progres)
        },
                                    success: { (task,response) in
                                        self.downloadFinished(url: url! as NSURL, object: response as Any, error: nil)
        },
                                    failure: { (task,error:Error!) in
                                        self.downloadFinished(url: url! as NSURL, object: nil, error: error! as NSError)
        })
        let taskOperation = VJBaseURLSessionTaskOperation(task: task!)
        //network reachability condition
        let networkObserver = VJBaseNetworkObserver()
        taskOperation.addObserver(observer: networkObserver)
        
        addOperation(operation: taskOperation)
    }
    
    func downloadFinished(url: NSURL?, object: Any?, error: NSError?) {
        
        
        if let error = error {
            aggregateError(error: error)
        }
        else if url != nil {
            self.scriptItem.previewRawImage = UIImage(data: object as! Data)
            //            do {
            //                /*
            //                 If we already have a file at this location, just delete it.
            //                 Also, swallow the error, because we don't really care about it.
            //                 */
            //                //删除cache中的旧数据
            //                try FileManager.default.removeItem(at: cacheFile as URL)
            //            }
            //            catch { }
            //
            //            do {
            //                //添加cache中的新数据
            //                try FileManager.default.moveItem(at: localURL as URL, to: cacheFile as URL)
            //            }
            //            catch let error as NSError {
            //                aggregateError(error: error)
            //            }
            
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
        finish()
    }
}
