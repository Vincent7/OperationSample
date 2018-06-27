//
//  ScriptObject.swift
//  Priam
//
//  Created by Vincent on 30/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
protocol ContextImageFilterable {
    var previewRawImage:UIImage? {get}
    var animFilterdImage:UIImage? {get set}
}
class ImageFilterableObject:NSObject,ContextImageFilterable{
    var previewRawImage:UIImage?
    var animFilterdImage:UIImage?
    
    init(rawImage:UIImage) {
        self.previewRawImage = rawImage
        super.init()
    }
}
class ScriptObject: NSObject,ContextImageFilterable {
    var identifier:String!
    
    var scriptName:String = ""
    var previewImageUrl:URL?
    
    var previewRawImage:UIImage?
    var animFilterdImage:UIImage?
//    var animFilterdImages:[UIImage] = []
    
    var previewTitle:String = ""
    
    init(identifier:String) {
        self.identifier = identifier
        self.previewImageUrl = URL(string: "http://renren.maoyun.tv/ftp/2018/0127/b_0d15d588d89fc58f2ecb6ad656b19ab9.jpg")!
        super.init()
    }
}
