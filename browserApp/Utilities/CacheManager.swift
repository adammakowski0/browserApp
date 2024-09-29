//
//  CacheManager.swift
//  browserApp
//
//  Created by Adam Makowski on 03/09/2024.
//

import Foundation
import SwiftUI

class CacheManager {
    static let instance = CacheManager()
//    private init() {}
    
    var cache: NSCache<NSString, UIImage> = {
        var cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200
        cache.totalCostLimit = 1024*1024*150
        return cache
    }()
    
    func add(key: String, value: UIImage){
        cache.setObject(value, forKey: key as NSString)
    }
    
    func get(key: String) -> UIImage?{
        return cache.object(forKey: key as NSString)
    }
}
