//
//  VJBaseOperationObserver.swift
//  OperationSample
//
//  Created by Vincent on 27/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import Foundation

protocol VJBaseOperationObserver {
    
    /// Invoked immediately prior to the `Operation`'s `execute()` method.
    func operationDidStart(operation: VJBaseOperation)
    
    /// Invoked when `Operation.produceOperation(_:)` is executed.
    func operation(operation: VJBaseOperation, didProduceOperation newOperation: Operation)
    
    /**
     Invoked as an `Operation` finishes, along with any errors produced during
     execution (or readiness evaluation).
     */
    func operationDidFinish(operation: VJBaseOperation, errors: [Error])
    
}
