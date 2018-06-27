//
//  VJScriptDetailViewController.swift
//  Priam
//
//  Created by Vincent on 2018/4/24.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class VJScriptDetailViewController: UIViewController {
    var imagePreviewView:VJPreviewImageTitleView?
//    let contentView = UIView()
    lazy var scrollView:UIScrollView? = {
        let scrollView = UIScrollView.init()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*3)
        scrollView.delegate = self
        return scrollView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.addSubview(scrollView!)
        scrollView!.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
//        scrollView?.addSubview(contentView)
//        contentView.snp.makeConstraints { (make) in
//            make.edges.width.equalTo(scrollView!)
//            make.top.equalTo(scrollView!)
//            make.height.greaterThanOrEqualTo(scrollView!)
//        }
        scrollView?.addSubview(imagePreviewView!)
        
        imagePreviewView?.snp.makeConstraints { (make) in
            make.top.equalTo(-20)
            make.width.equalTo(scrollView!)
            make.height.equalTo(scrollView!.snp.width).multipliedBy((imagePreviewView?.imageSize.height)!/(imagePreviewView?.imageSize.width)!)
            make.left.equalTo(0)
        }

        imagePreviewView?.delegate = self
//        imagePreviewView?.snp.makeConstraints { (make) in
//            make.edges.equalTo(view).inset(UIEdgeInsets.zero)
//        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    var collectionCellTransitionAnimation:VJCollectionCellTransitionAnimation?
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return collectionCellTransitionAnimation
    }
}
extension VJScriptDetailViewController:VJPreviewImageTitleViewDelegate{
    func didUnexpandCell(_ btnClose: UIButton, _ view: VJPreviewImageTitleView) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension VJScriptDetailViewController:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var previewAnimationOrginRect = scrollView.convert((self.imagePreviewView?.frame)!, to: nil)
        if Float(previewAnimationOrginRect.origin.y + (self.imagePreviewView?.bounds.height)!) < 0 {
            previewAnimationOrginRect.origin = CGPoint(x: 0.0, y: -Double((self.imagePreviewView?.bounds.height)!))
        }
        guard previewAnimationOrginRect.size != CGSize.zero else {
            return
        }
        self.collectionCellTransitionAnimation?.finalRect = previewAnimationOrginRect
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.height
        if bottomEdge >= scrollView.contentSize.height {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
