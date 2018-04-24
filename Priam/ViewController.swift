//
//  ViewController.swift
//  OperationSample
//
//  Created by Vincent on 29/01/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
import AFNetworking
import SnapKit
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UIScrollViewDelegate {
    var selectedIndex:IndexPath = IndexPath.init()
    var selectedItemPreviewFrame:CGRect = CGRect.init()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 1
        default:
            return 1
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:OSParallaxImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "parallaxCellIdentifier", for: indexPath) as!OSParallaxImageCollectionViewCell
        cell.lblScreenPlay.text = "The series takes place over 350 years in the future, in the year 2384."
        cell.delegate = self
//        cell.lblScreenPlay.text = "The series takes."
        var scriptObject = ScriptObject(identifier: indexPath.description)
        let scriptCreateOperation = ScriptListObjectCreateOperation(context: &scriptObject) {
            DispatchQueue.main.async {
//                cell.imgView.animationImages = scriptObject.animFilterdImages
//                cell.imgView.animationDuration = 1.5;//设置动画时间
//                cell.imgView.animationRepeatCount = 1;//设置动画次数 0 表示无限
//                cell.imgView.startAnimating()
                cell.imgView.image = scriptObject.previewRawImage
                cell.previewImgView.image = scriptObject.animFilterdImage
                let textColor:UIColor = (scriptObject.previewRawImage?.inverseColor())!
                UIView.animate(withDuration: 2, animations: {
                    cell.previewImgView.alpha = 0
                    cell.imgView.alpha = 1
                    cell.lblScreenPlay.textColor = textColor
                })
            }
        }
        scriptCreateOperation.userInitiated = true
        self.operationsManager.dQueue.addOperation(scriptCreateOperation)

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:OSParallaxImageCollectionViewCell = collectionView.cellForItem(at: indexPath) as! OSParallaxImageCollectionViewCell
        selectedIndex = indexPath
        selectedItemPreviewFrame = cell.frame
        collectionFlowLayout.invalidateLayout()
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
            cell.frame = collectionView.bounds
            cell.layoutIfNeeded()
            collectionView.isScrollEnabled = false
            cell.superview?.bringSubview(toFront: cell)
            cell.expandCell()
            
        }, completion: { (bool) in
            
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 5
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:OSImageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! OSImageTableViewCell
        let imageUrl:String = "http://renren.maoyun.tv/ftp/2018/0127/b_0d15d588d89fc58f2ecb6ad656b19ab9.jpg"
//        guard let cacheImage:OSNetworkImage = OSNetworkImage.getCache(imageUrl) as! OSNetworkImage else {
//            return <#return value#>
//
//        }
        let operation = OSHTTPSessionOperation.httpOperation(manager: sessionManager, httpMethod: .get, urlString: imageUrl, parameters: nil, uploadProgress:{ (progres) in
//            print(progres)
        }, downloadProgress:{ (progres) in
//            print(progres)
        }, completionHandler: { (task, responseObject, result) in
            switch result {
            case let .Success(successResult):
//                let serverResponse = successResult
                
                let image = UIImage(data: responseObject as! Data)
//                blurOperation = Operation.
//                cell.blurImageView.image = image
                let blurOperation = OSImageFiltrationOperation.init(index: indexPath)
                blurOperation.delegateImageView = cell.blurImageView
//                cell.blurImageView.animationImages = blur
                let updateImageOperation = BlockOperation.init(block: {
                    cell.blurImageView.animationImages = blurOperation.filteredImages
                    cell.blurImageView.animationDuration = 1.5;//设置动画时间
                    cell.blurImageView.animationRepeatCount = 1;//设置动画次数 0 表示无限
                    cell.blurImageView.startAnimating()
                    cell.blurImageView.image = image
                })
//                blurOperation.completionBlock
                updateImageOperation.addDependency(blurOperation)
                self.operationsManager.mainOperationsQueue.addOperation(blurOperation)
                OperationQueue.main.addOperation(updateImageOperation)
//                self.operationsManager.mainOperationsQueue.addOperation(updateImageOperation)
//                print(serverResponse,responseObject ?? "NO DATA")
                
            case let .Error(error):
                let serverResponse = error.description
                print(serverResponse)
            }
            
        })
        operationsManager.downloadQueue.addOperation(operation)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    lazy var sampleImageTableView:UITableView = {
        let tableView = UITableView.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OSImageTableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        return tableView
    }()
    lazy var collectionFlowLayout:OSImageListFlowLayout = {
        let layout:OSImageListFlowLayout = OSImageListFlowLayout.init()
        return layout
    }()
    lazy var imageCollectionView:UICollectionView = {
        let collectionView = UICollectionView.init(frame: CGRect.init(), collectionViewLayout: self.collectionFlowLayout)
        collectionView.register(OSParallaxImageCollectionViewCell.self, forCellWithReuseIdentifier: "parallaxCellIdentifier")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    lazy var sessionManager:AFHTTPSessionManager = {
        let urlCache = URLCache.init(memoryCapacity: 4*1024*1024,
                                     diskCapacity: 20*1024*1024,
                                     diskPath: nil)
        URLCache.shared = urlCache
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 15
        
        let sessionManager = AFHTTPSessionManager.init(sessionConfiguration: configuration)
        let responseSerializer = AFHTTPResponseSerializer.init()
        responseSerializer.acceptableContentTypes = Set(["application/json", "text/json", "text/javascript","text/html","image/webp","image/jpeg"])
//        sessionManager.requestSerializer = AFJSONRequestSerializer.seri
        sessionManager.responseSerializer = responseSerializer
        sessionManager.requestSerializer = AFHTTPRequestSerializer.init()
        return sessionManager
    }()
    let operationsManager = OSNetworkingOperationSession.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageCollectionView)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        collectionFlowLayout.invalidateLayout()
    }
}
// MARK: ScroolViewDelegate
extension ViewController {
    
    fileprivate func parallaxOffsetDidChange(_: CGFloat) {
        _ = imageCollectionView.visibleCells
            .forEach { if case let cell as OSParallaxImageCollectionViewCell = $0 { cell.parallaxOffset(imageCollectionView) } }
    }
}
extension ViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        parallaxOffsetDidChange(scrollView.contentOffset.y)
    }
//    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        parallaxOffsetDidChange(scrollView.contentOffset.y)
//    }
}
extension ViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectedIndex == indexPath {
            return collectionView.bounds.size
        }else{
            return CGSize(width: collectionView.bounds.width - 40, height: 400)
        }
        
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsetsMake(20, 0, 0, 0)
//    }
}
extension ViewController:OSParallaxImageCollectionViewCellDelegate{
    func didUnexpandCell(_ btnClose: UIButton,_ cell: OSParallaxImageCollectionViewCell) {
        selectedIndex = IndexPath.init()
        collectionFlowLayout.invalidateLayout()
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
            cell.frame = self.selectedItemPreviewFrame
            cell.layoutIfNeeded()
            //            self.imageCollectionView.collectionViewLayout.invalidateLayout()
            self.imageCollectionView.isScrollEnabled = true
            self.selectedItemPreviewFrame = CGRect.init()
        },completion:{ (bool) in
            
        })
    }

}
