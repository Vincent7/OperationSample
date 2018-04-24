//
//  VJBaseGroupOperation.swift
//  OperationSample
//
//  Created by Vincent on 28/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class VJBaseGroupOperation: VJBaseOperation {
    private let internalQueue = VJBaseOperationQueue()
    private let startingOperation = BlockOperation(block: {})
    private let finishingOperation = BlockOperation(block: {})
    
    private var aggregatedErrors = [Error]()
    
    convenience init(operations: Operation...) {
        self.init(operations: operations)
    }
    
    init(operations: [Operation]) {
        super.init()
        internalQueue.name = "Internal Queue"
        internalQueue.isSuspended = true
        internalQueue.delegate = self
        internalQueue.addOperation(startingOperation)
        
        for operation in operations {
            internalQueue.addOperation(operation)
        }
    }
    
    override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
    
    override func execute() {
        internalQueue.isSuspended = false
        internalQueue.addOperation(finishingOperation)
    }
    
    func addOperation(operation: Operation) {
        internalQueue.addOperation(operation)
    }
    
    /**
     Note that some part of execution has produced an error.
     Errors aggregated through this method will be included in the final array
     of errors reported to observers and to the `finished(_:)` method.
     */
    final func aggregateError(error: Error) {
        aggregatedErrors.append(error)
    }
    
    func operationDidFinish(operation: Operation, withErrors errors: [Error]) {
        // For use by subclassers.
    }
}
extension VJBaseGroupOperation: OperationQueueDelegate {
    final func operationQueue(operationQueue: VJBaseOperationQueue, willAddOperation operation: Operation) {
        assert(!finishingOperation.isFinished && !finishingOperation.isExecuting, "cannot add new operations to a group after the group has completed")
        
        /*
         Some operation in this group has produced a new operation to execute.
         We want to allow that operation to execute before the group completes,
         so we'll make the finishing operation dependent on this newly-produced operation.
         */
        if operation !== finishingOperation {
            finishingOperation.addDependency(operation)
        }
        
        /*
         All operations should be dependent on the "startingOperation".
         This way, we can guarantee that the conditions for other operations
         will not evaluate until just before the operation is about to run.
         Otherwise, the conditions could be evaluated at any time, even
         before the internal operation queue is unsuspended.
         */
        if operation !== startingOperation {
            operation.addDependency(startingOperation)
        }
    }
    final func operationQueue(operationQueue: VJBaseOperationQueue, operationDidFinish operation: Operation, withErrors errors: [Error]) {
        
        aggregatedErrors.append(contentsOf: errors)
        
        if operation === finishingOperation {
            internalQueue.isSuspended = true
            finish(errors: aggregatedErrors)
        }
        else if operation !== startingOperation {
            operationDidFinish(operation: operation, withErrors: errors)
        }
    }
}
