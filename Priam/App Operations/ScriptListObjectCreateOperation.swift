//
//  ScriptListObjectCreateOperation.swift
//  OperationSample
//
//  Created by Vincent on 29/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class ScriptListObjectCreateOperation: VJBaseGroupOperation {
    let downloadOperation: DownloadScriptPreviewOperation
    //解析下载数据
//    let parseOperation: ParseEarthquakesOperation
    let filterdImageOperation: VJImageFilterOperation
    
    init(context:inout ScriptObject, completionHandler: @escaping () -> Void) {
        //TODO: 取cache
        /*
         This operation is made of three child operations:
         1. The operation to download the JSON feed
         2. The operation to parse the JSON feed and insert the elements into the Core Data store
         3. The operation to invoke the completion handler
         */
        downloadOperation = DownloadScriptPreviewOperation(context: &context)
//        var imageFilterableObject:ImageFilterableObject = ImageFilterableObject()
        var tempContext:ContextImageFilterable = context as ContextImageFilterable
        filterdImageOperation = VJImageFilterOperation(context: &tempContext){ [context] in
            context.animFilterdImage = tempContext.animFilterdImage
        }
        
        let finishOperation = BlockOperation(block: completionHandler)
        
        // These operations must be executed in order
        filterdImageOperation.addDependency(downloadOperation)
        finishOperation.addDependency(filterdImageOperation)
        
        super.init(operations: [downloadOperation, filterdImageOperation, finishOperation])
        
        name = "Get Script List Item"
    }
    
}

