//
//  VJBaseOperation.swift
//  OperationSample
//
//  Created by Vincent on 27/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class VJBaseOperation: Operation {
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if key == "isFinished" || key == "isExecuting" || key == "isReady" {
            return ["state"]
        }
        else {
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }

    private enum State: Int, Comparable {
        case Initialized
        case Pending
        /// The `Operation` is evaluating conditions.
        case EvaluatingConditions
        case Ready
        case Executing
        case Finishing
        case Finished
        
        func canTransitionToState(target: State) -> Bool {
            switch (self, target) {
            case (.Initialized, .Pending):
                return true
            case (.Pending, .EvaluatingConditions):
                return true
            case (.EvaluatingConditions, .Ready):
                return true
            case (.Ready, .Executing):
                return true
            case (.Ready, .Finishing):
                return true
            case (.Executing, .Finishing):
                return true
            case (.Finishing, .Finished):
                return true
            default:
                return false
            }
        }
        
        static func <(lhs: VJBaseOperation.State, rhs: VJBaseOperation.State) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        static func ==(lhs: VJBaseOperation.State, rhs: VJBaseOperation.State) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
    
    func willEnqueue() {
        state = .Pending
    }
    
    /// Private storage for the `state` property that will be KVO observed.
    private var _state = State.Initialized
    
    /// A lock to guard reads and writes to the `_state` property
    private let stateLock = NSLock()
    private var state: State {
        get {
            return stateLock.withCriticalScope {
                _state
            }
        }
        
        set(newState) {
            /*
             It's important to note that the KVO notifications are NOT called from inside
             the lock. If they were, the app would deadlock, because in the middle of
             calling the `didChangeValueForKey()` method, the observers try to access
             properties like "isReady" or "isFinished". Since those methods also
             acquire the lock, then we'd be stuck waiting on our own lock. It's the
             classic definition of deadlock.
             */
            willChangeValue(forKey: "state")
            
            stateLock.withCriticalScope { () -> Void in
                guard _state != .Finished else {
                    return
                }
                
                assert(_state.canTransitionToState(target: newState), "Performing invalid state transition.")
                _state = newState
            }
            
            didChangeValue(forKey: "state")
        }
    }
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if let keyPath = "state" {
//            switch keyPath {
//            case "state":
//                
//            default:
//                break
//            }
//        }
//    }
    override var isReady: Bool {
        switch state {
            
        case .Initialized:
            return isCancelled
            
        case .Pending:
            guard !isCancelled else {
                return true
            }
            
            // If super isReady, conditions can be evaluated
            if super.isReady {
                evaluateConditions()
            }
            
            // Until conditions have been evaluated, "isReady" returns false
            return false
            
        case .Ready:
            return super.isReady || isCancelled
            
        default:
            return false
        }
    }
    
    var userInitiated: Bool {
        get {
            return qualityOfService == .userInitiated
        }
        
        set {
            assert(state < .Executing, "Cannot modify userInitiated after execution has begun.")
            
            qualityOfService = newValue ? .userInitiated : .default
        }
    }
    
    override var isExecuting: Bool {
        return state == .Executing
    }
    
    override var isFinished: Bool {
        return state == .Finished
    }
    
    private func evaluateConditions() {
        assert(state == .Pending && !isCancelled, "evaluateConditions() was called out-of-order")
        
        state = .EvaluatingConditions
        
        OperationConditionEvaluator.evaluate(conditions: conditions, operation: self) { failures in
            self._internalErrors.append(contentsOf: failures)
            self.state = .Ready
        }
    }

    // MARK: Observers and Conditions
    
    private(set) var conditions = [VJBaseOperationCondition]()
    
    func addCondition(condition: VJBaseOperationCondition) {
        assert(state < .EvaluatingConditions, "Cannot modify conditions after execution has begun.")
        
        conditions.append(condition)
    }
    
    private(set) var observers = [VJBaseOperationObserver]()
    
    func addObserver(observer: VJBaseOperationObserver) {
        assert(state < .Executing, "Cannot modify observers after execution has begun.")
        
        observers.append(observer)
    }
    
    override func addDependency(_ operation: Operation) {
        assert(state < .Executing, "Dependencies cannot be modified after execution has begun.")
        
        super.addDependency(operation)
    }
    
    // MARK: Execution and Cancellation
    
    override final func start() {
        // NSOperation.start() contains important logic that shouldn't be bypassed.
        super.start()
        
        // If the operation has been cancelled, we still need to enter the "Finished" state.
        if isCancelled {
            finish()
        }
    }
    
    override final func main() {
        assert(state == .Ready, "This operation must be performed on an operation queue.")
        
        if _internalErrors.isEmpty && !isCancelled {
            state = .Executing
            
            for observer in observers {
                observer.operationDidStart(operation: self)
            }
            
            execute()
        }
        else {
            finish()
        }
    }
    
    /**
     `execute()` is the entry point of execution for all `Operation` subclasses.
     If you subclass `Operation` and wish to customize its execution, you would
     do so by overriding the `execute()` method.
     
     At some point, your `Operation` subclass must call one of the "finish"
     methods defined below; this is how you indicate that your operation has
     finished its execution, and that operations dependent on yours can re-evaluate
     their readiness state.
     */
    func execute() {
        print("\(type(of: self)) must override `execute()`.")
        
        finish()
    }
    
    lazy private var _internalErrors:[Error] = {
        return [Error]()
    }()
    func cancelWithError(error: NSError? = nil) {
        if let error = error {
            _internalErrors.append(error)
        }
        
        cancel()
    }
    
    final func produceOperation(operation: Operation) {
        for observer in observers {
            observer.operation(operation: self, didProduceOperation: operation)
        }
    }
    
    // MARK: Finishing
    
    /**
     Most operations may finish with a single error, if they have one at all.
     This is a convenience method to simplify calling the actual `finish()`
     method. This is also useful if you wish to finish with an error provided
     by the system frameworks. As an example, see `DownloadEarthquakesOperation`
     for how an error from an `NSURLSession` is passed along via the
     `finishWithError()` method.
     */
    final func finishWithError(error: NSError?) {
        if let error = error {
            finish(errors: [error])
        }
        else {
            finish()
        }
    }
    
    /**
     A private property to ensure we only notify the observers once that the
     operation has finished.
     */
    private var hasFinishedAlready = false
    final func finish(errors: [Error] = []) {
        if !hasFinishedAlready {
            hasFinishedAlready = true
            state = .Finishing
            
            let combinedErrors = _internalErrors + errors
            finished(errors:combinedErrors)
            
            for observer in observers {
                observer.operationDidFinish(operation: self, errors: combinedErrors)
            }
            
            state = .Finished
        }
    }
    
    /**
     Subclasses may override `finished(_:)` if they wish to react to the operation
     finishing with errors. For example, the `LoadModelOperation` implements
     this method to potentially inform the user about an error when trying to
     bring up the Core Data stack.
     */
    func finished(errors: [Error]) {
        // No op.
    }
    
    override final func waitUntilFinished() {
        /*
         Waiting on operations is almost NEVER the right thing to do. It is
         usually superior to use proper locking constructs, such as `dispatch_semaphore_t`
         or `dispatch_group_notify`, or even `NSLocking` objects. Many developers
         use waiting when they should instead be chaining discrete operations
         together using dependencies.
         
         To reinforce this idea, invoking `waitUntilFinished()` will crash your
         app, as incentive for you to find a more appropriate way to express
         the behavior you're wishing to create.
         */
        fatalError("Waiting on operations is an anti-pattern. Remove this ONLY if you're absolutely sure there is No Other Way™.")
    }
    
    
}

