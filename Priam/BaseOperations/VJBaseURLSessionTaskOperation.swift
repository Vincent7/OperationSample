//
//  VJBaseNetworkTaskOperation.swift
//  OperationSample
//
//  Created by Vincent on 27/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
import AFNetworking

private var VJBaseURLSessionTaskOperationKVOContext = 0

class VJBaseURLSessionTaskOperation: VJBaseOperation {
    
    let task:URLSessionTask
    
    init(task: URLSessionTask) {
        assert(task.state == .suspended, "Tasks must be suspended.")
        self.task = task
        
        super.init()
        
    }
    
    override func execute() {
        assert(task.state == .suspended, "Task was resumed by something other than \(self).")
        
//        task.addObserver(self, forKeyPath: "state", options: [], context: &VJBaseURLSessionTaskOperationKVOContext)
        task.resume()
    }
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        guard context == &VJBaseURLSessionTaskOperationKVOContext else { return }
//
//        if object as! URLSessionTask === task && keyPath == "state" && task.state == .completed {
////            task.removeObserver(self, forKeyPath: "state")
//            NotificationCenter.default.removeObserver(self)
//            finish()
//        }
//    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
}
