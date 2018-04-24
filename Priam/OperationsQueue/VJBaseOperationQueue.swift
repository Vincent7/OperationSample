//
//  VJBaseOperationQueue.swift
//  OperationSample
//
//  Created by Vincent on 28/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

@objc protocol OperationQueueDelegate: NSObjectProtocol {
    @objc optional func operationQueue(operationQueue: VJBaseOperationQueue, willAddOperation operation: Operation)
    @objc optional func operationQueue(operationQueue: VJBaseOperationQueue, operationDidFinish operation: Operation, withErrors errors: [Error])
}
class VJBaseOperationQueue: OperationQueue {
    weak var delegate: OperationQueueDelegate?
    override init() {
        
        super.init()
//        name = "working queue"
    }
    override func addOperation(_ operation: Operation) {
        if let op = operation as? VJBaseOperation {
            // Set up a `BlockObserver` to invoke the `OperationQueueDelegate` method.
            let delegate = VJBaseOperationBlockObserver(startHandler: nil, produceHandler: { [weak self] (produceOperation, op) in
                self?.addOperation(op)
            }, finishHandler: { [weak self] (finishOperation, errors) in
                if let q = self {
                    q.delegate?.operationQueue?(operationQueue: q, operationDidFinish: finishOperation, withErrors: errors)
                }
            })
            op.addObserver(observer: delegate)
            
            // Extract any dependencies needed by this operation.
            let dependencies = op.conditions.flatMap {
                $0.dependencyForOperation(operation: op)
            }
            
            for dependency in dependencies {
                op.addDependency(dependency)
                
                self.addOperation(dependency)
            }
            
            /*
             With condition dependencies added, we can now see if this needs
             dependencies to enforce mutual exclusivity.
             */
            let concurrencyCategories: [String] = op.conditions.flatMap { condition in
                if !type(of: condition).isMutuallyExclusive {
                    return nil
                }
                
                return "\(type(of: condition))"
            }
            
            if !concurrencyCategories.isEmpty {
                // Set up the mutual exclusivity dependencies.
                let exclusivityController = ExclusivityController.sharedExclusivityController
                
                exclusivityController.addOperation(operation: op, categories: concurrencyCategories)
                
                op.addObserver(observer: VJBaseOperationBlockObserver { operation, _ in
                    exclusivityController.removeOperation(operation: operation, categories: concurrencyCategories)
                })
            }
            
            /*
             Indicate to the operation that we've finished our extra work on it
             and it's now it a state where it can proceed with evaluating conditions,
             if appropriate.
             */
            op.willEnqueue()
        }
        else {

            operation.addCompletionBlock(block: {[weak self, weak operation] in
                guard let queue = self, let operation = operation else {
                    return
                    
                }
                queue.delegate?.operationQueue?(operationQueue: queue, operationDidFinish: operation, withErrors: [])
            })

        }
        
        delegate?.operationQueue?(operationQueue: self, willAddOperation: operation)
        super.addOperation(operation)
    }
    override func addOperations(_ operations: [Operation], waitUntilFinished wait: Bool) {
        /*
         The base implementation of this method does not call `addOperation()`,
         so we'll call it ourselves.
         */
        for operation in operations {
            addOperation(operation)
        }
        
        if wait {
            for operation in operations {
                operation.waitUntilFinished()
            }
        }
    }
}
