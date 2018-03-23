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
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 5
        default:
            return 1
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:OSParallaxImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "parallaxCellIdentifier", for: indexPath) as!OSParallaxImageCollectionViewCell
        cell.lblScreenPlay.text = "Carbone Altered"
        var networkImage:OSNetworkImage = OSNetworkImage()
        let downloadImageOperation:OSImageHTTPSessionOperation = OSImageHTTPSessionOperation.httpOperation(manager: sessionManager,operationSession:operationsManager, httpMethod: .get, urlString: "http://renren.maoyun.tv/ftp/2018/0127/b_0d15d588d89fc58f2ecb6ad656b19ab9.jpg", parameters: nil, uploadProgress:{ (progres) in
            //            print(progres)
        }, downloadProgress:{ (progres) in
            //            print(progres)
        }, completionHandler: { (task, responseObject, result) in
            switch result {
            case .Success(_):

                let image = responseObject as! UIImage
            
                
            case let .Error(error):
                let serverResponse = error.description
                print(serverResponse)
            }
            
        }) as! OSImageHTTPSessionOperation

        
        let blurOperation = OSImageFiltrationOperation.init(index: indexPath)
        let adapterOp = BlockOperation(block: {
            blurOperation.rawImage  = downloadImageOperation.networkImage
        })
        blurOperation.delegateImageView = cell.imgView
        let updateImageOperation = BlockOperation.init(block: {
            cell.imgView.animationImages = blurOperation.filteredImages
            cell.imgView.animationDuration = 1.5;//设置动画时间
            cell.imgView.animationRepeatCount = 1;//设置动画次数 0 表示无限
            cell.imgView.startAnimating()
            cell.imgView.image = blurOperation.rawImage
        })
        //                blurOperation.completionBlock
        updateImageOperation.addDependency(blurOperation)
        adapterOp.addDependency(downloadImageOperation)
        blurOperation.addDependency(adapterOp)
        if !downloadImageOperation.isFinished {
            self.operationsManager.downloadQueue.addOperation(downloadImageOperation)
        }
//    self.operationsManager.mainOperationsQueue.addOperations([downloadImageOperation,adapterOp,blurOperation], waitUntilFinished: false)
        self.operationsManager.mainOperationsQueue.addOperation(adapterOp)
        self.operationsManager.mainOperationsQueue.addOperation(blurOperation)
        OperationQueue.main.addOperation(updateImageOperation)
        return cell
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
        collectionView.delegate = self
        collectionView.dataSource = self
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
        let operation = OSHTTPSessionOperation.httpOperation(manager: sessionManager, httpMethod: .get, urlString: "http://localhost:3000/scripts.json", parameters: nil, uploadProgress:{ (progres) in
//            print(progres)
        }, downloadProgress:{ (progres) in
//            print(progres)
        }, completionHandler: { (task, responseObject, result) in
            switch result {
            case let .Success(successResult):
                let serverResponse = successResult
//                print(serverResponse,responseObject ?? "NO DATA")
            case let .Error(error):
                let serverResponse = error.description
                print(serverResponse)
            }
            
        })
        operationsManager.downloadQueue.addOperation(operation)
        
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
