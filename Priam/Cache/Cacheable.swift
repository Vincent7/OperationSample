//
//  Cache.swift
//  Priam
//
//  Created by Vincent on 30/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import Foundation

protocol Cacheable {
//    let memoryCache:NSCache<String,Any>
//    let diskCachePath: String
    
    func getCache(identifier:String) -> Cacheable
    func updateCache(identifier:String)
}
