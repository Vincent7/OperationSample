//
//  NSLock+Operations.swift
//  OperationSample
//
//  Created by Vincent on 27/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import Foundation

extension NSLock {
    func withCriticalScope<T>( block: () -> T) -> T {
        lock()
        let criticalScopeValue = block()
        unlock()
        return criticalScopeValue
    }
}
