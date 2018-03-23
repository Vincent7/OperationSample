//
//  OSLoadImageCacheOperation.swift
//  OperationSample
//
//  Created by Vincent on 19/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class OSLoadImageCacheOperation: OSBaseAsynchronousOperation {
    var cacheImage:UIImage?
    var cacheIdentifier:String!
    init(identifier:String) {
        super.init()
        self.cacheIdentifier = identifier
        //        self.task = URLSessionTask()
    }
    override func main () {
        if self.isCancelled {
            return
        }
        cacheImage = (OSNetworkImage.getCache(identifier: self.cacheIdentifier) as! UIImage)
        completeOperation()
    }
}
