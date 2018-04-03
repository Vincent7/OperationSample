//
//  VJBaseBlockOperation.swift
//  OperationSample
//
//  Created by Vincent on 28/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

typealias OperationBlock = (() -> Void) -> Void

class VJBaseBlockOperation: VJBaseOperation {
    private let block: OperationBlock?
    
    /**
     The designated initializer.
     
     - parameter block: The closure to run when the operation executes. This
     closure will be run on an arbitrary queue. The parameter passed to the
     block **MUST** be invoked by your code, or else the `BlockOperation`
     will never finish executing. If this parameter is `nil`, the operation
     will immediately finish.
     */
    init(block: OperationBlock? = nil) {
        self.block = block
        super.init()
    }
    
    /**
     A convenience initializer to execute a block on the main queue.
     
     - parameter mainQueueBlock: The block to execute on the main queue. Note
     that this block does not have a "continuation" block to execute (unlike
     the designated initializer). The operation will be automatically ended
     after the `mainQueueBlock` is executed.
     */
    convenience init(mainQueueBlock: @escaping ()->Void) {
        self.init(block: { (continuation:@escaping () -> Void) in
//            DispatchQueue.async(DispatchQueue.main)
            DispatchQueue.main.async() {
                mainQueueBlock()
                continuation()
            }
        } as? OperationBlock)
    }
    
    override func execute() {
        guard let block = block else {
            finish()
            return
        }
        
        block {
            self.finish()
        }
    }
}
