//
//  OSParallaxImageCollectionViewCell.swift
//  OperationSample
//
//  Created by Vincent on 12/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class OSParallaxImageCollectionViewCell: UICollectionViewCell {
    lazy var previewImageTitleView:VJPreviewImageTitleView = {
        let view:VJPreviewImageTitleView = VJPreviewImageTitleView()
        view.parallaxOffset = parallaxOffset
        view.animState = .Folded
        return view
    }()
    
    var parallaxOffset:Float = 0{
        didSet{
            previewImageTitleView.foldParallaxOffset = parallaxOffset
            switch previewImageTitleView.animState {
            case .Folded:
                previewImageTitleView.parallaxOffset = parallaxOffset
                previewImageTitleView.setNeedsUpdateConstraints()
            default: break
                
            }
            
            
        }
    }
//    weak var delegate:OSParallaxImageCollectionViewCellDelegate?
//    @objc func touchCloseButton() -> () {
//        delegate?.didUnexpandCell?(btnClose,self)
//        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.allowUserInteraction, animations: {
//            self.btnClose.alpha = 0
//        }, completion: nil)
//    }
    
    override func updateConstraints() {
        super.updateConstraints()
//        previewImageTitleView.setNeedsUpdateConstraints()
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitControls()
        commonInitConstraints(parallaxOffsetY: parallaxOffset, imageSize: CGSize.init(width: 1000, height: 1500))
//        setNeedsUpdateConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitControls()
        commonInitConstraints(parallaxOffsetY: parallaxOffset, imageSize: CGSize.init(width: 1000, height: 1500))
//        setNeedsUpdateConstraints()
    }
    func commonInitControls() -> Void {
        backgroundColor = .clear
        contentView.clipsToBounds = true
        
        contentView.addSubview(previewImageTitleView)
    }
    func commonInitConstraints(parallaxOffsetY:Float, imageSize:CGSize) -> Void {
        previewImageTitleView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets.zero)
        }
    }
}
extension OSParallaxImageCollectionViewCell {
    
    func parallaxOffset(_ scrollView: UIScrollView) {
        
        var deltaY = (frame.origin.y + frame.height / 2) - scrollView.contentOffset.y
        deltaY = min(scrollView.bounds.height, max(deltaY, 0)) // range
        
        var move: Float = Float((deltaY / scrollView.bounds.height) * 100)
        move = move / 2.0 - move
        parallaxOffset = move
        
    }
}


