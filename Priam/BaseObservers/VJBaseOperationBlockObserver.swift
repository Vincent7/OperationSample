//
//  VJBaseOperationBlockObserver.swift
//  OperationSample
//
//  Created by Vincent on 28/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

struct VJBaseOperationBlockObserver: VJBaseOperationObserver {
    // MARK: Properties
    
    private let startHandler: ((VJBaseOperation) -> Void)?
    private let produceHandler: ((VJBaseOperation, Operation) -> Void)?
    private let finishHandler: ((VJBaseOperation, [NSError]) -> Void)?
    
    init(startHandler: ((VJBaseOperation) -> Void)? = nil, produceHandler: ((VJBaseOperation, Operation) -> Void)? = nil, finishHandler: ((VJBaseOperation, [NSError]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: OperationObserver
    
    func operationDidStart(operation: VJBaseOperation) {
        startHandler?(operation)
    }
    
    func operation(operation: VJBaseOperation, didProduceOperation newOperation: Operation) {
        produceHandler?(operation, newOperation)
    }
    
    func operationDidFinish(operation: VJBaseOperation, errors: [NSError]) {
        finishHandler?(operation, errors)
    }
}
