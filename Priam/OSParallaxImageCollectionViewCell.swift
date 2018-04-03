//
//  OSParallaxImageCollectionViewCell.swift
//  OperationSample
//
//  Created by Vincent on 12/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class OSParallaxImageCollectionViewCell: UICollectionViewCell {
    lazy var imgView:UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    lazy var lblScreenPlay:UITextView = {
        let textView = UITextView.init()
        return textView
    }()
    
    var parallaxOffset:Float = 0
    
    
    override func updateConstraints() {
        imgView.snp.updateConstraints { (make) in
            make.top.equalTo(parallaxOffset)
        }
        super.updateConstraints()
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
        backgroundColor = UIColor.orange
        contentView.clipsToBounds = true
        contentView.addSubview(lblScreenPlay)
        contentView.addSubview(imgView)
    }
    func commonInitConstraints(parallaxOffsetY:Float, imageSize:CGSize) -> Void {
        imgView.snp.makeConstraints { (make) in
            make.height.equalTo(contentView.snp.width).multipliedBy(imageSize.height/imageSize.width)
            make.left.equalTo(contentView.snp.left)
            make.top.equalTo(parallaxOffsetY)
            make.right.equalTo(contentView.snp.right)
        }
        
        lblScreenPlay.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.left.equalTo(contentView.snp.left).offset(16)
            make.top.equalTo(contentView.snp.top).offset(16)
            make.right.equalTo(contentView.snp.right).offset(-16)
        }
    }
}
extension OSParallaxImageCollectionViewCell {
    
    func parallaxOffset(_ scrollView: UIScrollView) {
        
//        guard let bgImageY = self.bgImageY, isMovedHidden == false else {
//            return
//        }
        
        var deltaY = (frame.origin.y + frame.height / 2) - scrollView.contentOffset.y
        deltaY = min(scrollView.bounds.height, max(deltaY, 0)) // range
        
        var move: Float = Float((deltaY / scrollView.bounds.height) * 100)
        move = move / 2.0 - move
        parallaxOffset = move
        setNeedsUpdateConstraints()
    }
}


