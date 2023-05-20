//
//  ImageCacher.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

/// A simple implementation for caching images: in-memory & on-disk
class ImageCacher {
    
    private var cache: NSCache<NSURL, UIImage> = NSCache()
    private let fileManager = FileManager.default
    private let cacheDirectoryURL: URL
    
    static let shared: ImageCacher = try! .init()
    
    private init() throws {
        cacheDirectoryURL = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    func image(for url: URL?) async throws -> UIImage? {
        guard let url else { return nil }
        
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }
        
        let cacheFileURL = cacheDirectoryURL.appendingPathComponent(url.lastPathComponent)
        if let data = try? Data(contentsOf: cacheFileURL),
           let image = UIImage(data: data) {
            cache.setObject(image, forKey: url as NSURL)
            return image
        }
        
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
        
        #warning("FIXME: - slow down loading to see shimmering animation")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let image = UIImage(data: data)
        if let img = image {
            cache.setObject(img, forKey: url as NSURL)
        }
        
        
        try fileManager.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true)
        try data.write(to: cacheFileURL, options: .atomic)
        
        return image
    }
    
}
