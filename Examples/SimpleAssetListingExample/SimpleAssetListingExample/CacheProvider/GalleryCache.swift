// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation

/// Values tracked by our file cache
/// Since our cache is utilizing Etags, we need to track the Etag value for each file URL that we store
/// The cache itself look up these values based on the identifier of the asset that we have downloaded
public class GalleryFileCacheValue: Codable {
    var filename: String
    var etag: String?
    
    init(filename: String, etag: String?) {
        self.filename = filename
        self.etag = etag
    }
}

/// This is the cache that is used to keep track of files which have been downloaded.
/// Each downloaded file will have a URL and ETag - persisted as part of an `ARDemoFileCache` object
/// Lookup of cached values is done via the asset's identifier value
/// - important The gallery cache is cleared at the start of each execution of the sample code. To change this behavior, modify the code in MainView.swift's init method.
public class GalleryFileCache: ObservableObject, Codable {
    
    public static var instance = GalleryFileCache()
    
    static let fileLocation = FileManager.default
                                         .urls(for: .documentDirectory, in: .userDomainMask)[0]
                                         .appendingPathComponent("GalleryFileCache.json")
    
    public static let deviceCacheLocation = FileManager
        .default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("savedFiles")
    
    var items: [String: GalleryFileCacheValue]
    
    private init() {
        
        do {
            var isDir : ObjCBool = true
            if FileManager.default.fileExists(atPath: GalleryFileCache.deviceCacheLocation.path, isDirectory: &isDir) {
                
                // This should not happen - where a FILE exists with the name of the expected FOLDER
                if !isDir.boolValue {
                    try FileManager.default.removeItem(at: GalleryFileCache.deviceCacheLocation)
                    try FileManager.default.createDirectory(at: GalleryFileCache.deviceCacheLocation, withIntermediateDirectories: true)
                }
            } else {
                // Create the folder into which we will persist downloaded files
                try FileManager.default.createDirectory(at: GalleryFileCache.deviceCacheLocation, withIntermediateDirectories: true)
            }
        } catch let error {
            // We should never hit this code
            fatalError("Unexpected error initializing the device cache location. Error: \(error)")
        }
        
        if let cache = GalleryFileCache.read() {
            self.items = cache
        } else {
            self.items = [:]
        }
    }
}

public extension GalleryFileCache {
    
    static func read() -> [String: GalleryFileCacheValue]? {
        do {
            let data = try Data(contentsOf: GalleryFileCache.fileLocation)
            let persistedValues = try JSONDecoder().decode([String: GalleryFileCacheValue].self, from: data)
            return persistedValues
        } catch {
            print(error)
            return nil
        }
    }
    
    /// Saves a downloaded file into the cache and updates the JSON listing associating the file identifier with the filename and etag
    static func saveDownloadedFile(key: String, etag: String, downloadedFileURL: URL) throws -> URL {
        
        // move the file from the tmp directory to the saved files directory
        let downloadedFilename = downloadedFileURL.lastPathComponent
        let newURL = self.deviceCacheLocation.appendingPathComponent(downloadedFilename)
        
        if FileManager.default.fileExists(atPath: newURL.path) {
            try FileManager.default.removeItem(at: newURL)
        }
        
        try FileManager.default.moveItem(at: downloadedFileURL, to: newURL)
       
        // persist the permanent file location in the cache
        GalleryFileCache.instance.items[key] = GalleryFileCacheValue(filename: downloadedFilename, etag: etag)

        GalleryFileCache.instance.write()
        
        return newURL
    }
    
    /// Returns the URL for the cached file corresponding to the requested key
    static func cachedItem(key: String) -> URL? {
        if let foundValue = GalleryFileCache.instance.items[key] {
            let url = GalleryFileCache.deviceCacheLocation.appendingPathComponent(foundValue.filename)
            return url
        } else {
            return nil
        }
    }
    
    func write() {
        
        guard let data = try? JSONEncoder().encode(self.items) else {
            print("foo")
            return
        }
        
        do {
            try data.write(to: GalleryFileCache.fileLocation)
        } catch {
            print(error)
        }
        
    }
    
    func clear() {
        
        let jsonData = "{ }".data(using: .utf8)!
        do {
            try jsonData.write(to: GalleryFileCache.fileLocation)
            self.items = [:]
            
            try FileManager.default.removeItem(at: GalleryFileCache.deviceCacheLocation)
            try FileManager.default.createDirectory(at: GalleryFileCache.deviceCacheLocation, withIntermediateDirectories: true)
            
        } catch {
            print(error)
        }
    }
}
