//
//  Operation+VJBaseOperation.swift
//  OperationSample
//
//  Created by Vincent on 28/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import Foundation
extension Operation {
    /**
     Add a completion block to be executed after the `NSOperation` enters the
     "finished" state.
     */
    func addCompletionBlock(block:@escaping () -> Void) {
        if let existing = completionBlock {
            /*
             If we already have a completion block, we construct a new one by
             chaining them together.
             */
            completionBlock = {
                existing()
                block()
            }
        }
        else {
            completionBlock = block
        }
    }
    
    /// Add multiple depdendencies to the operation.
    func addDependencies(dependencies: [Operation]) {
        for dependency in dependencies {
            addDependency(dependency)
        }
    }
}
