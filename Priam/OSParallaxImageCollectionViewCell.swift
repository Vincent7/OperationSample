//
//  OSParallaxImageCollectionViewCell.swift
//  OperationSample
//
//  Created by Vincent on 12/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
@objc protocol OSParallaxImageCollectionViewCellDelegate {
//    @objc optional func didExpandCell(_ btnClose:UIButton, atIndexPath indexPath:IndexPath) -> ()
    @objc optional func didUnexpandCell(_ btnClose:UIButton,_ cell:OSParallaxImageCollectionViewCell) -> ()
}
class OSParallaxImageCollectionViewCell: UICollectionViewCell {
    lazy var previewImgView:UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    lazy var imgView:UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    lazy var lblScreenPlay:UILabel = {
        let textView = UILabel.init()
        textView.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        textView.textColor = UIColor.white
        textView.numberOfLines = 0
        textView.textAlignment = .natural
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    lazy var btnClose:UIButton = {
        let btn = UIButton.init()
        btn.setImage(UIImage.init(named: "Rounded_Close_Button"), for: .normal)
        btn.setTitle(nil, for: .normal)
        btn.alpha = 0
        btn.addTarget(self, action: #selector(touchCloseButton), for: .touchUpInside)
        return btn
    }()
    var parallaxOffset:Float = 0
    weak var delegate:OSParallaxImageCollectionViewCellDelegate?
    @objc func touchCloseButton() -> () {
        delegate?.didUnexpandCell?(btnClose,self)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.btnClose.alpha = 0
        }, completion: nil)
    }
    func expandCell() -> () {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.btnClose.alpha = 1
            }, completion: nil)
    }
    override func updateConstraints() {
        imgView.snp.updateConstraints { (make) in
            make.top.equalTo(parallaxOffset)
        }
        previewImgView.snp.updateConstraints { (make) in
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
        
        contentView.addSubview(imgView)
        contentView.addSubview(previewImgView)
        contentView.addSubview(lblScreenPlay)
        contentView.addSubview(btnClose)
    }
    func commonInitConstraints(parallaxOffsetY:Float, imageSize:CGSize) -> Void {
        imgView.snp.makeConstraints { (make) in
            make.height.equalTo(contentView.snp.width).multipliedBy(imageSize.height/imageSize.width)
//            make.left.equalTo(contentView.snp.left)
//            make.top.equalTo(parallaxOffsetY)
//            make.right.equalTo(contentView.snp.right)
            make.width.equalToSuperview()
            make.top.equalTo(parallaxOffsetY)
            make.centerX.equalTo(contentView)
        }
        previewImgView.snp.makeConstraints { (make) in
            make.height.equalTo(contentView.snp.width).multipliedBy(imageSize.height/imageSize.width)
            make.width.equalToSuperview()
            make.top.equalTo(parallaxOffsetY)
            make.centerX.equalTo(contentView)
        }
        lblScreenPlay.snp.makeConstraints { (make) in

            make.height.equalTo(self.snp.height).offset(-40)
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(20)
            make.right.equalTo(self.snp.right).offset(-20)

        }
        btnClose.snp.makeConstraints { (make) in
            
            make.height.equalTo(60)
            make.width.equalTo(60)
            make.top.equalTo(20)
            make.right.equalTo(self.snp.right).offset(-20)
            
            //            make.height.equalToSuperview().offset(-20)
            //            make.width.equalToSuperview().offset(-20)
            //            make.top.equalTo(20)
            //            make.centerX.equalTo(contentView)
        }
    }
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
////        setNeedsLayout()
////        layoutIfNeeded()
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var newFrame = layoutAttributes.frame
//        // note: don't change the width
//        newFrame.size.height = ceil(400)
//        newFrame.size.width = ceil(275 - 20)
//        layoutAttributes.frame = newFrame
//        return layoutAttributes
//
//    }
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//    }
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


