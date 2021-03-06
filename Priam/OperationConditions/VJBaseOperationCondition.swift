//
//  VJBaseOperationCondition.swift
//  OperationSample
//
//  Created by Vincent on 27/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import Foundation

let OperationConditionKey = "OperationCondition"

/**
 A protocol for defining conditions that must be satisfied in order for an
 operation to begin execution.
 */
protocol VJBaseOperationCondition {
    /**
     The name of the condition. This is used in userInfo dictionaries of `.ConditionFailed`
     errors as the value of the `OperationConditionKey` key.
     */
    static var name: String { get }
    
    /**
     Specifies whether multiple instances of the conditionalized operation may
     be executing simultaneously.
     */
    static var isMutuallyExclusive: Bool { get }
    
    /**
     Some conditions may have the ability to satisfy the condition if another
     operation is executed first. Use this method to return an operation that
     (for example) asks for permission to perform the operation
     
     - parameter operation: The `Operation` to which the Condition has been added.
     - returns: An `NSOperation`, if a dependency should be automatically added. Otherwise, `nil`.
     - note: Only a single operation may be returned as a dependency. If you
     find that you need to return multiple operations, then you should be
     expressing that as multiple conditions. Alternatively, you could return
     a single `GroupOperation` that executes multiple operations internally.
     */
    func dependencyForOperation(operation: Operation) -> Operation?
    
    /// Evaluate the condition, to see if it has been satisfied or not.
    func evaluateForOperation(operation: Operation, completion: (OperationConditionResult) -> Void)
}

/**
 An enum to indicate whether an `OperationCondition` was satisfied, or if it
 failed with an error.
 */
enum OperationConditionResult: Equatable {
    case Satisfied
    case Failed(NSError)
    
    var error: NSError? {
        if case .Failed(let error) = self {
            return error
        }
        
        return nil
    }
}

func ==(lhs: OperationConditionResult, rhs: OperationConditionResult) -> Bool {
    switch (lhs, rhs) {
    case (.Satisfied, .Satisfied):
        return true
    case (.Failed(let lError), .Failed(let rError)) where lError == rError:
        return true
    default:
        return false
    }
}

// MARK: Evaluate Conditions

struct OperationConditionEvaluator {
    static func evaluate(conditions: [VJBaseOperationCondition], operation: Operation, completion: @escaping ([NSError]) -> Void) {
        // Check conditions.
        let conditionGroup = DispatchGroup()
        
        var results = [OperationConditionResult?](repeating: nil, count: conditions.count)
        
        // Ask each condition to evaluate and store its result in the "results" array.
        for (index, condition) in conditions.enumerated() {
            conditionGroup.enter()
            condition.evaluateForOperation(operation: operation) { result in
                results[index] = result
                conditionGroup.leave()
            }
        }
        
        // After all the conditions have evaluated, this block will execute.
        conditionGroup.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
//            var failures = results.flatMap {
//                $0?.error
//
//            }
            var failures = results.flatMap({ (result) -> NSError in
                (result?.error)!
            })
            /*
             If any of the conditions caused this operation to be cancelled,
             check for that.
             */
            if operation.isCancelled {
                failures.append(NSError(code: .ConditionFailed))
            }
            
            completion(failures)
        }
    }
}
