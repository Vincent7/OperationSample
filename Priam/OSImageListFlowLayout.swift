//
//  OSImageListFlowLayout.swift
//  OperationSample
//
//  Created by Vincent on 13/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class OSImageListFlowLayout: UICollectionViewFlowLayout {
    var dynamicAnimator:UIDynamicAnimator?
    override init() {
        super.init()
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
        sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        itemSize = UICollectionViewFlowLayoutAutomaticSize
        estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        
        dynamicAnimator = UIDynamicAnimator.init(collectionViewLayout: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepare() {
        super.prepare()
        let contentSize:CGSize = self.collectionViewContentSize
        let items:Array<UIDynamicItem> = super.layoutAttributesForElements(in: CGRect.init(origin: CGPoint.zero, size: contentSize))!
        if (dynamicAnimator?.behaviors.count == 0){
            for (_, object) in items.enumerated() {
                let behaviour:UIAttachmentBehavior = UIAttachmentBehavior.init(item: object, attachedToAnchor: object.center)
                behaviour.length = 0.0
                behaviour.damping = 0.8
                behaviour.frequency = 1.0
                dynamicAnimator?.addBehavior(behaviour)
            }

        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return dynamicAnimator?.items(in: rect) as? [UICollectionViewLayoutAttributes]
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return dynamicAnimator?.layoutAttributesForCell(at:indexPath)
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let scrollView:UIScrollView = self.collectionView as! UIScrollView
        let delta:Float = Float(newBounds.origin.y - scrollView.bounds.origin.y)
        
        let touchLocation:CGPoint = (self.collectionView?.panGestureRecognizer.location(in: self.collectionView))!
        for (_,springBehaviour) in ((self.dynamicAnimator?.behaviors as! Array<UIAttachmentBehavior>).enumerated()) {
            let yDistanceFromTouch:Float = fabsf(Float(touchLocation.y - springBehaviour.anchorPoint.y))
            let xDistanceFromTouch:Float = fabsf(Float(touchLocation.x - springBehaviour.anchorPoint.x))
            let scrollResistance:Float = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0
            
            let item:UICollectionViewLayoutAttributes = springBehaviour.items.first as! UICollectionViewLayoutAttributes
            var center:CGPoint = item.center
            
            if (delta < 0) {
                center.y += CGFloat(max(delta, delta*scrollResistance))
            }
            else {
                center.y += CGFloat(min(delta, delta*scrollResistance))
            }
            item.center = center;
            dynamicAnimator?.updateItem(usingCurrentState: item)
        }
        return false
    }
}
