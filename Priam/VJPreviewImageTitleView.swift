//
//  VJPreviewImageTitleView.swift
//  Priam
//
//  Created by Vincent on 2018/4/25.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
import SnapKit
@objc protocol VJPreviewImageTitleViewDelegate {
    
    //    @objc optional func didExpandCell(_ btnClose:UIButton, atIndexPath indexPath:IndexPath) -> ()
    @objc optional func didUnexpandCell(_ btnClose:UIButton,_ view:VJPreviewImageTitleView) -> ()
}
class VJPreviewImageTitleView: UIView {
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if key == "isFolded" || key == "isUnfolding" || key == "isUnfolded" || key == "isFolding"{
            return ["animState"]
        }
        else {
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }
    var _animState = AnimState.Init
    var animState: AnimState {
        get {
            return _animState
        }
        
        set(newState) {
            willChangeValue(forKey: "animState")
            assert(_animState.canTransitionToState(target: newState), "Performing invalid state transition.")
            _animState = newState
            didChangeValue(forKey: "animState")
        }
    }
    override func value(forKey key: String) -> Any? {
        if key == "animState" {
            return self.animState
        }
        return super.value(forKey: key)
    }
    enum AnimState: Int{
        case Init
        case Folded
        case Unfolding
        case Unfolded
        case Folding
        
        func canTransitionToState(target: AnimState) -> Bool {
            guard self == .Init else {
                switch (self, target) {
                case (.Folded, .Unfolding):
                    return true
                case (.Unfolding, .Unfolded):
                    return true
                case (.Unfolded, .Folding):
                    return true
                case (.Folding, .Folded):
                    return true
                default:
                    return false
                }
            }
            return true
        }
    }
    var isFolded: Bool {
        return animState == .Folded
    }
    
    var isUnfolding: Bool {
        return animState == .Unfolding
    }
    
    var isUnfolded: Bool {
        return animState == .Unfolded
    }
    
    var isFolding: Bool {
        return animState == .Folding
    }
    private static var VJPreviewImageTitleAnimationStateContext = 0
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &VJPreviewImageTitleView.VJPreviewImageTitleAnimationStateContext {
            switch keyPath {
            case "animState":
                let newValue:AnimState = change![NSKeyValueChangeKey.newKey] as! AnimState
                if newValue == .Unfolding {
                    self.unfoldAnimation()
//                    self.parallaxOffset = 0
//                    self.updateConstraints()
                }
                if newValue == .Folding {
                    self.foldAnimation()
//                    self.parallaxOffset = self.foldParallaxOffset
//                    self.updateConstraints()
                }
                if newValue == .Unfolded {
                    self.btnClose.alpha = 1
                    self.parallaxOffset = 0
                    self.updateConstraints()
                }
                if newValue == .Folded {
                    self.btnClose.alpha = 0
                    self.parallaxOffset = self.foldParallaxOffset
                    self.updateConstraints()
                }
            default:
                return
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    var parallaxOffset:Float = 0
    var foldParallaxOffset:Float = 0
    var imageSize:CGSize = CGSize(width: 1000, height: 1500)
    weak var delegate:VJPreviewImageTitleViewDelegate?
    
    lazy var btnClose:UIButton = {
        let btn = UIButton.init()
        btn.setImage(UIImage.init(named: "Rounded_Close_Button"), for: .normal)
        btn.setTitle(nil, for: .normal)
        btn.alpha = 0
        btn.addTarget(self, action: #selector(touchCloseButton), for: .touchUpInside)
        return btn
    }()
    @objc func touchCloseButton() -> () {
        self.foldView()
        delegate?.didUnexpandCell?(btnClose,self)
    }
    func foldView() -> Void {
        animState = .Folding
    }
    func unfoldView() -> Void {
        animState = .Unfolding
    }
    func foldAnimation() -> Void {
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .allowAnimatedContent, animations: {
            self.btnClose.alpha = 0
        }) { (finished) in
            self.animState = .Folded
        }
    }
    func unfoldAnimation() -> Void {
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.btnClose.alpha = 1
        }, completion: { (finished) in
            self.animState = .Unfolded
        })
    }
    lazy var previewImgView:UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    lazy var originImgView:UIImageView = {
        let imageView = UIImageView.init()

        imageView.contentMode = .scaleToFill
        return imageView
    }()
    lazy var lblTitle:UILabel = {
        let textView = UILabel.init()
        textView.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        textView.textColor = UIColor.white
        textView.numberOfLines = 0
        textView.textAlignment = .natural
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }
    
    convenience init() {
        self.init(frame: CGRect.init())
    }
    
    
    func didLoad() {
        self.addObserver(self, forKeyPath: "animState", options: .new, context: &VJPreviewImageTitleView.VJPreviewImageTitleAnimationStateContext)
//        self.state = .Folded
        
        self.clipsToBounds = true
    
        self.addSubview(originImgView)
        self.addSubview(previewImgView)
        self.addSubview(lblTitle)
        self.addSubview(btnClose)
        //Place your initialization code here
        initConstraints()
        
        //I actually create & place constraints in here, instead of in
        //updateConstraints
    }
    func initConstraints(){
        
        originImgView.snp.makeConstraints { (make) in
            make.height.equalTo(self.snp.width).multipliedBy(imageSize.height/imageSize.width)
            make.width.equalToSuperview()
            make.top.equalTo(parallaxOffset)
            make.centerX.equalTo(self)
        }
        previewImgView.snp.makeConstraints { (make) in
            make.height.equalTo(self.snp.width).multipliedBy(imageSize.height/imageSize.width)
            make.width.equalToSuperview()
            make.top.equalTo(parallaxOffset)
            make.centerX.equalTo(self)
        }
        
        btnClose.snp.makeConstraints { (make) in
            
            make.height.equalTo(60)
            make.width.equalTo(60)
            make.top.equalTo(20)
            make.right.equalTo(self.snp.right).offset(-20)
        }
        lblTitle.snp.makeConstraints { (make) in
            
            make.height.equalTo(self.snp.height).offset(-40)
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(20)
            make.right.equalTo(self.snp.right).offset(-20)
//            make.width.equalTo((superview?.snp.width)!).offset(-40)
        }
        
    }

    
    override func updateConstraints() {
        
//        if (superview?.frame.width)! > CGFloat(0.0) {
//            lblTitle.snp.remakeConstraints { (make) in
//
//                make.height.equalTo(self.snp.height).offset(-40)
//                make.left.equalTo(self.snp.left).offset(20)
//                make.top.equalTo(20)
//                //            make.right.equalTo(self.snp.right).offset(-20)
//                make.width.equalTo((superview?.snp.width)!).offset(-40)
//            }
//        }
        originImgView.snp.updateConstraints { (make) in
            make.top.equalTo(parallaxOffset)
        }
        previewImgView.snp.updateConstraints { (make) in
            make.top.equalTo(parallaxOffset)
        }
        
        
        super.updateConstraints()
    }
    func createPreviewCopy(state:AnimState) -> VJPreviewImageTitleView {
        let copy:VJPreviewImageTitleView = VJPreviewImageTitleView()
        copy.foldParallaxOffset = self.foldParallaxOffset
        copy.parallaxOffset = self.parallaxOffset
        copy.lblTitle.text = self.lblTitle.text
        copy.lblTitle.textColor = self.lblTitle.textColor

        copy.originImgView.image = self.originImgView.image
        copy.originImgView.alpha = self.originImgView.alpha
        copy.previewImgView.image = self.previewImgView.image
        copy.previewImgView.alpha = self.previewImgView.alpha
        copy.btnClose.alpha = self.btnClose.alpha
        copy.animState = state
        
        return copy
    }
    
    func resetLabelWidth(width:CGFloat){
        lblTitle.snp.remakeConstraints { (make) in
            
            make.height.equalTo(self.snp.height).offset(-40)
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(20)
            make.width.equalTo(width)
        }
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
extension VJPreviewImageTitleView:VJCollectionCellTransitionObject{
    func presentedTransitionPreClosure(preFrame: CGRect) {
        self.snp.remakeConstraints { (make) in
            make.top.equalTo(preFrame.origin.y)
            make.left.equalTo(preFrame.origin.x)
            make.width.equalTo(preFrame.width)
            make.height.equalTo(preFrame.height)
        }
        resetLabelWidth(width: preFrame.width-40)
        unfoldView()
        layoutIfNeeded()
//        updateConstraints()
        superview?.layoutIfNeeded()
    }
    
    func presentedTransitionPostClosure(postFrame: CGRect) {
        self.snp.updateConstraints { (make) in
            make.top.equalTo(postFrame.origin.y)
            make.left.equalTo(postFrame.origin.x)
            make.width.equalTo(postFrame.width)
            
//            make.height.equalTo(375).multipliedBy(1.5)
            make.height.equalTo(postFrame.height)
        }
        
        superview?.updateConstraints()
        parallaxOffset = 0
        updateConstraints()
    }
    
    func dismissedTransitionPreClosure(preFrame: CGRect) {
        self.snp.remakeConstraints { (make) in
            make.top.equalTo(preFrame.origin.y)
            make.left.equalTo(preFrame.origin.x)
            make.width.equalTo(preFrame.width)
            make.height.equalTo(preFrame.height)
        }
        lblTitle.snp.remakeConstraints { (make) in
            
            make.height.equalTo(self.snp.height).offset(-40)
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(20)
            make.right.equalTo(self.snp.right).offset(-20)
        }
        foldView()
        superview?.layoutIfNeeded()
    }
    
    func dismissedTransitionPostClosure(postFrame: CGRect) {
        self.snp.updateConstraints { (make) in
            make.top.equalTo(postFrame.origin.y)
            make.left.equalTo(postFrame.origin.x)
            make.width.equalTo(postFrame.width)
            make.height.equalTo(postFrame.height)
            
        }
        parallaxOffset = foldParallaxOffset
        updateConstraints()
    }

}
