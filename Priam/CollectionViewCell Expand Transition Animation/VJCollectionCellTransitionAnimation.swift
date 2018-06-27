//
//  VJCollectionCellTransitionAnimation.swift
//  Priam
//
//  Created by Vincent on 2018/4/24.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
protocol VJCollectionCellTransitionProtocol:NSObjectProtocol{
    
    var sourceCellFrame: CGRect? { get }
    var sourceView: UIView? { get }
    var copyView: UIView? { get }
    var collectionView: UICollectionView? { get }
    var view: UIView! { get }
}
typealias InteractionClosure = (_ frame: CGRect) -> Void
protocol VJCollectionCellTransitionObject:NSObjectProtocol{
    
    func presentedTransitionPreClosure(preFrame:CGRect)
    func presentedTransitionPostClosure(postFrame:CGRect)
    
    func dismissedTransitionPreClosure(preFrame:CGRect)
    func dismissedTransitionPostClosure(postFrame:CGRect)
}

class VJCollectionCellTransitionAnimation: NSObject,UIViewControllerAnimatedTransitioning {
    var sourceAnimationView:(UIView & VJCollectionCellTransitionObject)?
    var sourceAnimationRect:CGRect? = CGRect.zero
    var finalRect:CGRect? = CGRect.zero
    
    var backgroundImageView:UIImageView?
    var backgroundImage:UIImage?
    var bluredBackgroundImageView:UIImageView?
    var bluredBackgroundImage:UIImage?
    
    let operationsManager = OSOperationSession.sharedInstance
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 4.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        
        let toVC:UIViewController = transitionContext.viewController(forKey: .to)!
        let fromVC:UIViewController = transitionContext.viewController(forKey: .from)!
        
        let containerView = transitionContext.containerView
//        containerView.backgroundColor = .white
        
        let animationDuration = transitionDuration(using: transitionContext)
        let animDamping:CGFloat = 0.8
        let animVelocity:CGFloat = 0.2
        
        if toVC.isBeingPresented {
            let fromAnimationObject:VJCollectionCellTransitionProtocol = fromVC as! VJCollectionCellTransitionProtocol
            sourceAnimationRect = fromAnimationObject.sourceCellFrame
            sourceAnimationView = fromAnimationObject.copyView as? (UIView & VJCollectionCellTransitionObject)
            
            backgroundImage = fromVC.view.takeSnapShot(currentView: fromAnimationObject.view, addViews: [], hideViews: [fromAnimationObject.sourceView!])
            backgroundImageView = UIImageView(image: backgroundImage)
            
            
            backgroundImageView?.backgroundColor = .clear
            let toVCFrame = transitionContext.finalFrame(for: toVC)
            finalRect = CGRect(origin: toVCFrame.origin, size: CGSize(width: toVCFrame.width, height: toVCFrame.width*1.5))

            containerView.addSubview(toVC.view)
            containerView.addSubview(backgroundImageView!)
            containerView.addSubview(sourceAnimationView!)
            
            let filterableObject:ImageFilterableObject = ImageFilterableObject(rawImage:backgroundImage!)
            var tempContext:ContextImageFilterable = filterableObject as ContextImageFilterable
            let filterdImageOperation:VJImageFilterOperation = VJImageFilterOperation(context: &tempContext){ [filterableObject] in
                filterableObject.animFilterdImage = tempContext.animFilterdImage
                self.bluredBackgroundImage = filterableObject.animFilterdImage
                
                DispatchQueue.main.async {
                    self.bluredBackgroundImageView = UIImageView(image: self.bluredBackgroundImage)
                    self.bluredBackgroundImageView?.alpha = 0
                    
                    containerView.addSubview(self.bluredBackgroundImageView!)
                    containerView.bringSubview(toFront: self.sourceAnimationView!)
                    containerView.bringSubview(toFront: toVC.view)
                    
                    self.bluredBackgroundImageView!.snp.makeConstraints { (make) in
                        make.edges.equalTo(containerView).inset(UIEdgeInsets.zero)
                    }
                    
                    UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: animDamping, initialSpringVelocity: animVelocity, options: .beginFromCurrentState, animations: {
                        self.bluredBackgroundImageView?.alpha = 1
                        self.backgroundImageView?.alpha = 0
                        
                    }) { (finished) in
                        
                    }
                }
            }
            filterdImageOperation.userInitiated = true
            self.operationsManager.dQueue.addOperation(filterdImageOperation)
            
            backgroundImageView?.snp.makeConstraints { (make) in
                make.edges.equalTo(containerView).inset(UIEdgeInsets.zero)
            }
            
            sourceAnimationView?.presentedTransitionPreClosure(preFrame: sourceAnimationRect!)
            
            containerView.bringSubview(toFront: toVC.view)
            
            sourceAnimationView?.presentedTransitionPostClosure(postFrame: self.finalRect!)
            
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: animDamping, initialSpringVelocity: animVelocity, options: .beginFromCurrentState, animations: {

                self.sourceAnimationView?.layoutIfNeeded()
                containerView.layoutIfNeeded()

            }) { (finished) in
                self.bluredBackgroundImageView!.removeFromSuperview()
                self.backgroundImageView!.removeFromSuperview()
                self.sourceAnimationView?.removeFromSuperview()
                transitionContext.completeTransition(finished)
            }
        }
        
        if fromVC.isBeingDismissed {
            containerView.addSubview(toVC.view)
            containerView.addSubview(backgroundImageView!)
            containerView.addSubview(bluredBackgroundImageView!)
            containerView.addSubview(sourceAnimationView!)

            backgroundImageView?.alpha = 1
            
            backgroundImageView?.snp.makeConstraints { (make) in
                make.edges.equalTo(containerView).inset(UIEdgeInsets.zero)
            }
            bluredBackgroundImageView?.snp.makeConstraints { (make) in
                make.edges.equalTo(containerView).inset(UIEdgeInsets.zero)
            }
            sourceAnimationView?.dismissedTransitionPreClosure(preFrame: finalRect!)
            sourceAnimationView?.dismissedTransitionPostClosure(postFrame: sourceAnimationRect!)
            
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: animDamping, initialSpringVelocity: animVelocity, options: .beginFromCurrentState, animations: {
                self.bluredBackgroundImageView?.alpha = 0
                self.backgroundImageView?.alpha = 1
                self.sourceAnimationView?.layoutIfNeeded()
                containerView.layoutIfNeeded()
            }) { (finished) in
                self.bluredBackgroundImageView!.removeFromSuperview()
                self.backgroundImageView!.removeFromSuperview()
                self.sourceAnimationView?.removeFromSuperview()
                transitionContext.completeTransition(finished)
            }
        }
        
//        let cellView = transitionContext.view(forKey: .from)
        
        
        
//        let screenBounds:CGRect = UIScreen.main.bounds
        
        
//        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//
//        // 2. Set init frame for toVC
//        CGRect screenBounds = [[UIScreen mainScreen] bounds];
//        CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
//        toVC.view.frame = CGRectOffset(finalFrame, 0, screenBounds.size.height);
//
//        // 3. Add toVC's view to containerView
//        UIView *containerView = [transitionContext containerView];
//        [containerView addSubview:toVC.view];
//
//        // 4. Do animate now
//        NSTimeInterval duration = [self transitionDuration:transitionContext];
//        [UIView animateWithDuration:duration
//            delay:0.0
//            usingSpringWithDamping:0.6
//            initialSpringVelocity:0.0
//            options:UIViewAnimationOptionCurveLinear
//            animations:^{
//            toVC.view.frame = finalFrame;
//            } completion:^(BOOL finished) {
//            // 5. Tell context that we completed.
//            [transitionContext completeTransition:YES];
//            }];
    }
    
    
    
    
}
