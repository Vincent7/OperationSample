//
//  ExclusivityController.swift
//  OperationSample
//
//  Created by Vincent on 28/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class ExclusivityController: NSObject {
    static let sharedExclusivityController = ExclusivityController()
    
    private let serialQueue = DispatchQueue(label: "Operations.ExclusivityController")
    private var operations: [String: [VJBaseOperation]] = [:]
    
    private override init() {
        /*
         A private initializer effectively prevents any other part of the app
         from accidentally creating an instance.
         */
    }
    
    /// Registers an operation as being mutually exclusive
    func addOperation(operation: VJBaseOperation, categories: [String]) {
        /*
         This needs to be a synchronous operation.
         If this were async, then we might not get around to adding dependencies
         until after the operation had already begun, which would be incorrect.
         */
        serialQueue.sync() {
            for category in categories {
                self.noqueue_addOperation(operation: operation, category: category)
            }
        }
    }
    
    /// Unregisters an operation from being mutually exclusive.
    func removeOperation(operation: VJBaseOperation, categories: [String]) {
        serialQueue.async() {
            for category in categories {
                self.noqueue_removeOperation(operation: operation, category: category)
            }
        }
    }
    
    
    // MARK: Operation Management
    
    private func noqueue_addOperation(operation: VJBaseOperation, category: String) {
        var operationsWithThisCategory = operations[category] ?? []
        
        if let last = operationsWithThisCategory.last {
            operation.addDependency(last)
        }
        
        operationsWithThisCategory.append(operation)
        
        operations[category] = operationsWithThisCategory
    }
    
    private func noqueue_removeOperation(operation: VJBaseOperation, category: String) {
        let matchingOperations = operations[category]
        
        if var operationsWithThisCategory = matchingOperations,
            let index = operationsWithThisCategory.index(of: operation) {
            
            operationsWithThisCategory.remove(at: index)
            operations[category] = operationsWithThisCategory
        }
    }
}
