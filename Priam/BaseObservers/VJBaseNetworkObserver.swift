//
//  VJBaseNetworkObserver.swift
//  Priam
//
//  Created by Vincent on 30/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import Foundation
import AFNetworking
struct VJBaseNetworkObserver: VJBaseOperationObserver {
    // MARK: Initilization
    
    init() { }
    
    func operationDidStart(operation: VJBaseOperation) {
        DispatchQueue.main.async {
            NetworkIndicatorController.sharedIndicatorController.networkActivityDidStart()
        }
    }
    
    func operation(operation: VJBaseOperation, didProduceOperation newOperation: Operation) {
        
    }
    
    func operationDidFinish(operation: VJBaseOperation, errors: [Error]) {
        DispatchQueue.main.async {
            // Decrement the network indicator's "reference count".
            NetworkIndicatorController.sharedIndicatorController.networkActivityDidEnd()
        }
    }
    
}

/// A singleton to manage a visual "reference count" on the network activity indicator.
private class NetworkIndicatorController {
    // MARK: Properties
    
    static let sharedIndicatorController = NetworkIndicatorController()
    
    private var activityCount:Int = 0
    
    private var visibilityTimer: ObserverTimer?
    
    // MARK: Methods
    
    func networkActivityDidStart() {
        assert(Thread.isMainThread, "Altering network activity indicator state can only be done on the main thread.")
        
        activityCount = activityCount + 1
        
        updateIndicatorVisibility()
    }
    
    func networkActivityDidEnd() {
        assert(Thread.isMainThread, "Altering network activity indicator state can only be done on the main thread.")
        
        activityCount = activityCount - 1
        
        updateIndicatorVisibility()
    }
    
    private func updateIndicatorVisibility() {
        if activityCount > 0 {
            showIndicator()
        }
        else {
            /*
             To prevent the indicator from flickering on and off, we delay the
             hiding of the indicator by one second. This provides the chance
             to come in and invalidate the timer before it fires.
             */
            visibilityTimer = ObserverTimer(interval: 1.0) {
                self.hideIndicator()
            }
        }
    }
    
    private func showIndicator() {
        visibilityTimer?.cancel()
        visibilityTimer = nil
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideIndicator() {
        visibilityTimer?.cancel()
        visibilityTimer = nil
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

/// Essentially a cancellable `dispatch_after`.
class ObserverTimer {
    // MARK: Properties
    
    private var isCancelled = false
    
    // MARK: Initialization
    
    init(interval: TimeInterval, handler: @escaping ()->Void) {
        
        let when = DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: when + interval * Double(NSEC_PER_SEC)) { [weak self] in
            if self?.isCancelled == false {
                handler()
            }
        }
    }
    
    func cancel() {
        isCancelled = true
    }
}
